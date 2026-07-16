# syntax=docker/dockerfile:1
#
# Multi-stage build for Holodeck B2B.
# Build:  docker build -t devopsfixefy/holodeck:latest .
# Run:    docker run --rm -p 8080:8080 devopsfixefy/holodeck:latest

FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /src

COPY pom.xml ./
COPY modules ./modules

RUN mvn -B -DskipTests package

RUN mkdir /dist \
    && unzip -q modules/holodeckb2b-distribution/target/holodeckb2b-*.zip -d /dist \
    && mv /dist/holodeckb2b-* /dist/holodeck-b2b

FROM eclipse-temurin:21-jre-jammy

ENV HB2B_HOME=/holodeck-b2b \
    JAVA_HOME=/opt/java/openjdk \
    LANG=C.UTF-8

COPY --from=builder /dist/holodeck-b2b ${HB2B_HOME}

RUN set -eux; \
    groupadd --system --gid 1000 holodeck; \
    useradd --system --uid 1000 --gid holodeck --home-dir ${HB2B_HOME} --shell /usr/sbin/nologin holodeck; \
    chmod 755 ${HB2B_HOME}/bin/*.sh; \
    mkdir -p ${HB2B_HOME}/logs ${HB2B_HOME}/data ${HB2B_HOME}/temp ${HB2B_HOME}/conf/pmodes; \
    chown -R holodeck:holodeck ${HB2B_HOME}

WORKDIR ${HB2B_HOME}

USER holodeck

EXPOSE 8080

VOLUME ["${HB2B_HOME}/data", "${HB2B_HOME}/conf", "${HB2B_HOME}/logs"]

ENTRYPOINT ["/holodeck-b2b/bin/startServer.sh"]
