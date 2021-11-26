# GraalVM Native Image-based function init-images

You can create a set of function init-images (boilerplate generators) by either
running the `build.sh` script with no arguments (Fn and GraalVM versions will be
read from `fnfdk.version` and `graalvm.version`) or by defining the Fn FDK and
GraalVM versions in the following environment variables before running `build.sh`:
* FNFDK_VERSION
* GRAALVM_VERSION

The generated function projects use [mostly static linking](https://www.graalvm.org/reference-manual/native-image/StaticImages/)
which allows compiled function executables to be deployed on any container image with glibc available.  The default deployment image is the Google distroless image [gcr.io/distroless/base](https://github.com/GoogleContainerTools/distroless/blob/main/base/README.md), but [frolvlad/alpine-glibc](https://hub.docker.com/r/frolvlad/alpine-glibc) also works.  Both are about the same size.

NOTE: Java 17 init-image upport is ready but commented out until Fn FDK images for 17 are available.

### Credit

Forked and extracted from github.com/fnproject/fdk-project
