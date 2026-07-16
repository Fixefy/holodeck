# syntax=docker/dockerfile:1
#
# Holodeck B2B runtime image based on the official distribution package.
# file-backend is not published to Maven Central, so we use the upstream
# release zip (which already includes it) rather than building from source.
#
# Build:  docker build -t devopsfixefy/holodeck:latest .
# Run:    docker run --rm -p 8080:8080 devopsfixefy/holodeck:latest

ARG HOLODECK_VERSION=8.1.1

FROM eclipse-temurin:21-jre-jammy

ARG HOLODECK_VERSION
ARG HOLODECK_DIST_URL=https://github.com/holodeck-b2b/Holodeck-B2B/releases/download/v${HOLODECK_VERSION}/holodeckb2b-distribution-${HOLODECK_VERSION}.zip

ENV HB2B_HOME=/holodeck-b2b \
    JAVA_HOME=/opt/java/openjdk \
    LANG=C.UTF-8

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl unzip ca-certificates; \
    curl -fsSL "${HOLODECK_DIST_URL}" -o /tmp/holodeck.zip; \
    unzip -q /tmp/holodeck.zip -d /tmp; \
    mv "/tmp/holodeckb2b-${HOLODECK_VERSION}" "${HB2B_HOME}"; \
    rm -rf /tmp/holodeck.zip /var/lib/apt/lists/*; \
    groupadd --system --gid 1000 holodeck; \
    useradd --system --uid 1000 --gid holodeck --home-dir "${HB2B_HOME}" --shell /usr/sbin/nologin holodeck; \
    chmod 755 "${HB2B_HOME}"/bin/*.sh; \
    mkdir -p "${HB2B_HOME}/logs" "${HB2B_HOME}/data" "${HB2B_HOME}/temp" "${HB2B_HOME}/conf/pmodes"; \
    chown -R holodeck:holodeck "${HB2B_HOME}"

WORKDIR ${HB2B_HOME}

USER holodeck

EXPOSE 8080

VOLUME ["${HB2B_HOME}/data", "${HB2B_HOME}/conf", "${HB2B_HOME}/logs"]

ENTRYPOINT ["/holodeck-b2b/bin/startServer.sh"]
