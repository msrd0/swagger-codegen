FROM jimschubert/8-jdk-alpine-mvn:1.0

RUN set -x && \
    apk add --no-cache bash

ENV GEN_DIR /opt/swagger-codegen
WORKDIR ${GEN_DIR}
VOLUME  ${MAVEN_HOME}/.m2/repository

# Required from a licensing standpoint
COPY ./LICENSE ${GEN_DIR}

# Required to compile swagger-codegen
COPY ./google_checkstyle.xml ${GEN_DIR}

# Modules are copied individually here to allow for caching of docker layers between major.minor versions
COPY ./modules/swagger-codegen-maven-plugin ${GEN_DIR}/modules/swagger-codegen-maven-plugin
COPY ./modules/swagger-codegen-cli ${GEN_DIR}/modules/swagger-codegen-cli
COPY ./modules/swagger-codegen ${GEN_DIR}/modules/swagger-codegen
COPY ./modules/swagger-generator ${GEN_DIR}/modules/swagger-generator
COPY ./pom.xml ${GEN_DIR}/pom.xml

# Pre-compile swagger-codegen-cli
RUN mvn -am -pl "modules/swagger-codegen-cli" package

CMD ["help"]

##################################################################################################################

FROM openjdk:8-alpine

COPY --from=0 /opt/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar /usr/share/java/swagger-codegen-cli.jar
RUN echo 'java -jar /usr/share/java/swagger-codegen-cli.jar "$@"' >/usr/bin/swagger-codegen \
	&& chmod +x /usr/bin/swagger-codegen

CMD ["/bin/sh"]
