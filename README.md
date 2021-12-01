# GraalVM Native Image-based function init-images

You can create a set of function init-images (boilerplate generators) by either
running the `build.sh` script with no arguments (Fn and GraalVM versions will be
read from `fnfdk.version` and `graalvm.version`) or by defining the Fn FDK and
GraalVM versions in the following environment variables before running
`build.sh`:
* FNFDK_VERSION
* GRAALVM_VERSION

The generated function projects use [mostly static
linking](https://www.graalvm.org/reference-manual/native-image/StaticImages/)
which allows compiled function executables to be deployed on any container image
with glibc available.  The default deployment image is the Google distroless
image
[gcr.io/distroless/base](https://github.com/GoogleContainerTools/distroless/blob/main/base/README.md),
but [frolvlad/alpine-glibc](https://hub.docker.com/r/frolvlad/alpine-glibc) also
works.  Both are about the same size.

NOTE: Java 17 init-image upport is ready but commented out until Fn FDK images for 17 are available.

## Using init-images

Once built, you can generate a starter function using the `fn` CLI.  The syntax is:
```sh
fn init --init image <INIT IMAGE NAME>:jdk<JAVA VERSION>-<FDK VERSION> <FUNCTION NAME>
```
e.g.,
```sh
fn init --init-image fnproject/fn-java-graalvm-ee-init:jdk11-1.0.141 myfunc
```
This will generate a function named `myfunc` in folder of the same name.
To build the function you invoke `fn build` as you would for any Fn function.  The
build instructions for the function are defined in a `Dockerfile` which can be
customized as needed.

### Function Names

A Java class will be generated for the function with a legal Java name derived from
the provided function name.  Snake case with underscores (e.g., my_func) and kebab case
with dashes (e.g, my-func) are supported and will result in a camel case function
class name (e.g., MyFunc).  

### Credits

Forked and extracted from github.com/fnproject/fdk-project to prototype updates
to GraalVM container image structure changes.
