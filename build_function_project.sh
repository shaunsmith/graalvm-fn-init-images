#!/bin/sh

touch generation.log
if [ -n ${FN_FUNCTION_NAME} ]
then
    if [[ ${FN_FUNCTION_NAME:0:1} =~ ^[A-Za-z] ]]
    then
        JAVA_NAME=$(echo ${FN_FUNCTION_NAME} | sed -r 's/(^|[-_])([a-z0-9])/\U\2/g')
        echo "LOG: JAVA_NAME is: ${JAVA_NAME}" >> generation.log 
        if [[ ${JAVA_NAME} =~ ^[A-Za-z0-9]*$ ]]
        then
            sed -i -e "s|<artifactId>hello</artifactId>|<artifactId>${FN_FUNCTION_NAME}</artifactId>|" pom.xml
            sed -i -e "s|com.example.fn.HelloFunction|com.example.fn.${JAVA_NAME}|" Dockerfile
            sed -i -e "s|com.example.fn.HelloFunction|com.example.fn.${JAVA_NAME}|" src/main/resources/META-INF/native-image/fnfunction/reflect-config.json
            sed -i -e "s|HelloFunction|${JAVA_NAME}|" src/main/java/com/example/fn/HelloFunction.java
            mv src/main/java/com/example/fn/HelloFunction.java "src/main/java/com/example/fn/${JAVA_NAME}.java"
            sed -i -e "s|HelloFunction|${JAVA_NAME}|" src/test/java/com/example/fn/HelloFunctionTest.java
            mv src/test/java/com/example/fn/HelloFunctionTest.java "src/test/java/com/example/fn/${JAVA_NAME}Test.java"
        else
            echo "ERROR: Java function class name may not contain special characters: ${JAVA_NAME}" >> generation.log
        fi
    else
        echo "ERROR: Function name must start with a letter" >> generation.log
    fi
fi
tar c generation.log src pom.xml func.init.yaml .mvn mvnw Dockerfile 
