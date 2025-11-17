ARG MOODLE_VERSION=latest

FROM bitnamilegacy/moodle:${MOODLE_VERSION}

# generate german language files
RUN sed -i 's/^# de_DE.UTF-8 UTF-8$/de_DE.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

RUN apt update && apt install curl unzip jq -y
COPY opt/adler /opt/adler
COPY plugins.json /opt/adler

HEALTHCHECK --start-period=16m CMD curl -f http://localhost:8080 || exit 1

ENTRYPOINT [ "/opt/adler/entrypoint_adler.sh" ]
CMD [ "/opt/bitnami/scripts/moodle/run.sh" ]

