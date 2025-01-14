# GraalVM Native Image-based function init-images

You can create a set of function init-images (boilerplate generators) for
supported GraalVM releases by either running the `build.sh` script with no
arguments (Fn will be read from `fnfdk.version`) or by defining the Fn FDK in
the `FNFDK_VERSION` environment variable before running.

E.g.,
```sh
FNFDK_VERSION=1.0.198 GRAALVM_BUILD_TOOLS_VERSION=0.10.2 ./build.sh
```

The generated function projects use [mostly static
linking](https://www.graalvm.org/latest/reference-manual/native-image/guides/build-static-executables/)
which allows compiled function executables to be deployed on any container image
with glibc available. Users of the init-image can easily edit the generated
Dockerfile to specify the deployment image. The default deployment base image is
slim Oracle Linux but Distoless Base
([gcr.io/distroless/base](https://github.com/GoogleContainerTools/distroless/blob/main/base/README.md)),
and Alpine with glibc
([frolvlad/alpine-glibc](https://hub.docker.com/r/frolvlad/alpine-glibc)) also
work.

The fully qualified tag of each generated init-images is of the format: `<INIT IMAGE NAME>:jdk<JAVA VERSION>-ol<ORACLE LINUX VERSION>-fdk<FDK VERSION>`.
For example a tag could be `jdk17-ol8-fdk1.0.175`. The same image will be tagged with just the JDK number for ease of use, e.g., `jdk17`.

## Using init-images

Once built, you can generate a starter function using the `fn` CLI.  The syntax is:
```sh
fn init --init-image <INIT IMAGE NAME>:jdk<JAVA VERSION> <FUNCTION NAME>
```
e.g.,
```sh
fn init --init-image fnproject/fn-java-graalvm-init:jdk17 myfunc
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
