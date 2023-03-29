#
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM ##GRAALVM_IMAGE## as graalvm

## Build and native compile function
WORKDIR /function
ENV MAVEN_OPTS=-Dmaven.repo.local=/usr/share/maven/ref/repository
ADD mvnw mvnw
ADD .mvn .mvn
ADD pom.xml pom.xml
## Speed up subsequent builds by caching dependencies before copying in src
RUN ["./mvnw", "package", "dependency:copy-dependencies",  "-DincludeScope=runtime", "-DskipTests=true", "-Dmdep.prependGroupId=true", "-DoutputDirectory=target"]
ADD src src
## Build and test bytecode
RUN ["./mvnw", "test"]
## Generate Native Executable
RUN ["./mvnw", "-Pnative", "-DskipTests", "package"]

# need socket library from Fn FDK
FROM fnproject/fn-java-fdk:##FN_FDK_TAG## as fdk

# FROM may be any Linux container image with glibc, e.g.,
#  gcr.io/distroless/base
#  frolvlad/alpine-glibc
#  debian:buster-slim
FROM oraclelinux:8-slim
WORKDIR /function
COPY --from=graalvm /function/target/func func
COPY --from=fdk /function/runtime/lib/* ./
ENTRYPOINT ["./func", "-XX:MaximumHeapSizePercent=80", "-Djava.library.path=/function"]
CMD [ "com.example.fn.HelloFunction::handleRequest" ]
