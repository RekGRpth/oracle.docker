FROM alpine
MAINTAINER RekGRpth
ENTRYPOINT [ "docker_entrypoint.sh" ]
ADD bin /usr/local/bin
ENV GROUP=oracle \
    HOME=/home \
    LD_PRELOAD=/usr/local/lib/fakeglibc.so \
    USER=oracle
ADD fakeglibc.c "${HOME}/src/"
WORKDIR "${HOME}"
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gcc \
        make \
        musl-dev \
    ; \
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
    gcc -c fakeglibc.c -fPIC -o fakeglibc.o; \
    gcc -shared -o /usr/local/lib/fakeglibc.so -fPIC fakeglibc.o; \
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip; \
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip; \
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip; \
    unzip instantclient-basiclite-linuxx64.zip; \
    unzip instantclient-sdk-linuxx64.zip; \
    unzip instantclient-sqlplus-linuxx64.zip; \
    mkdir -p /usr/local/include /usr/local/bin /usr/local/lib; \
    cp -r instantclient*/sdk/include/*.h /usr/local/include/; \
    cp -r instantclient*/*.so* /usr/local/lib/; \
    cp -r instantclient*/sqlplus /usr/local/bin/; \
    cd "${HOME}"; \
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1; \
    ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2; \
    ln -s /lib64/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2; \
    apk add --no-cache --virtual .oracle-rundeps \
        libaio \
        libc6-compat \
        libnsl \
        shadow \
        su-exec \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    chmod +x /usr/local/bin/*; \
    echo done
