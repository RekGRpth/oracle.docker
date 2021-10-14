#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/oracle.docker
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create oracle
docker stop oracle || echo $?
docker rm oracle || echo $?
docker run \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname oracle \
    --interactive \
    --mount type=volume,source=oracle,destination=/home \
    --name oracle \
    --network name=docker \
    --rm \
    --tty \
    ghcr.io/rekgrpth/oracle.docker su-exec oracle:oracle sqlplus
