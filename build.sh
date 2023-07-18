#!/bin/sh
#
# Copyright (c) 2019, 2021 Oracle and/or its affiliates. All rights reserved.
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

set -e

if [ -z "${FNFDK_VERSION}" ];  then
    FNFDK_VERSION=$(cat fnfdk.version)
fi

if [ -z "${GRAALVM_BUILD_TOOLS_VERSION}" ];  then
    GRAALVM_BUILD_TOOLS_VERSION=$(cat graalvm-build-tools.version)
fi

# If using containerd: export DOCKER_CLI=nerdctl
DOCKER_CLI=${DOCKER_CLI:-"docker"}

generateImage() {
    local java_version="${1}"
    local ol_version="${2}"
    local graalvm_image_name=${3}
    local init_image_name=${4}
    local graalvm_image_and_tag="${graalvm_image_name}:${java_version}-ol${ol_version}" # latest Java CPU
    local fn_fdk_build_tag="${FNFDK_VERSION}"
    local fn_fdk_tag="${FNFDK_VERSION}"
    if [ ${java_version} -gt 8 ] 
    then
        fn_fdk_build_tag="jdk${java_version}-${FNFDK_VERSION}"
        fn_fdk_tag="jre${java_version}-${FNFDK_VERSION}"
    fi

    # Update pom.xml with current FDK version
    sed -i.bak -e "s|<fdk\\.version>.*</fdk\\.version>|<fdk.version>${FNFDK_VERSION}</fdk.version>|" pom.xml && rm pom.xml.bak

    # Update pom.xml with current GraalVM Build Tools version
    sed -i.bak -e "s|<native\\.maven\\.plugin\\.version>.*</native\\.maven\\.plugin\\.version>|<native.maven.plugin.version>${GRAALVM_BUILD_TOOLS_VERSION}</native.maven.plugin.version>|" pom.xml && rm pom.xml.bak

    # Update pom.xml with Java source/target
    cp pom.xml pom.build
    sed -i.bak \
        -e "s|<source>.*</source>|<source>${java_version}</source>|" \
        -e "s|<target>.*</target>|<target>${java_version}</target>|" \
        pom.build && rm pom.build.bak

    # Create Dockerfile with current FDK build tag
    cp Dockerfile Dockerfile.build
    sed -i.bak \
        -e "s|##FN_FDK_TAG##|${fn_fdk_tag}|" \
        -e "s|##FN_FDK_BUILD_TAG##|${fn_fdk_build_tag}|" \
        -e "s|##GRAALVM_IMAGE##|${graalvm_image_and_tag}|" \
        -e "s|##OL_VERSION##|${ol_version}|" \
        Dockerfile.build && rm Dockerfile.build.bak   


    #remove the builderInstance if already exist already created
    ${DOCKER_CLI} buildx rm builderInstance || true
    #create a builder instance and use it
    ${DOCKER_CLI} buildx create --use --name builderInstance

    #build multiarch image packaging creataed Dockerfile
    local full_image_name_with_tag="${init_image_name}:jdk${java_version}-ol${ol_version}-fdk${FNFDK_VERSION}"
    ${DOCKER_CLI} buildx build --no-cache --provenance=false --push\
    --platform linux/arm64/v8,linux/amd64\
     -f Dockerfile-init-image -t ${full_image_name_with_tag}  --output "type=registry,oci-mediatypes=false" .
    rm Dockerfile.build pom.build

#    # Build init image packaging created Dockerfile
#    local full_image_name_with_tag="${init_image_name}:jdk${java_version}-ol${ol_version}-fdk${FNFDK_VERSION}"
#    ${DOCKER_CLI} build -t ${full_image_name_with_tag} -f Dockerfile-init-image .
#    ${DOCKER_CLI} tag ${full_image_name_with_tag} ${init_image_name}:jdk${java_version}-fdk${FNFDK_VERSION}
#    ${DOCKER_CLI} tag ${full_image_name_with_tag} ${init_image_name}:jdk${java_version}-ol${ol_version}
#    ${DOCKER_CLI} tag ${full_image_name_with_tag} ${init_image_name}:jdk${java_version}
#    rm Dockerfile.build pom.build
}

# Oracle GraalVM Init Images
#generateImage 17 8 "container-registry.oracle.com/graalvm/native-image-ee" "fnproject/fn-java-graalvm-init"
generateImage 17 8 "ghcr.io/graalvm/native-image-community" "fnproject/fn-java-graalvm-community-init"
