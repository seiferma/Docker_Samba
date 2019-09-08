FROM alpine:latest

WORKDIR /samba

ENV USER_GROUP=smbusers
ENV VOL_CFG=/samba/cfg
ENV VOL_HOME=/samba/home

RUN VERSION=4.10.8-r0 && \
    apk --no-cache add samba=${VERSION} && \
    VERSION= && \
    addgroup -g 2500 ${USER_GROUP}

VOLUME ["${VOL_CFG}", "${VOL_HOME}"]

EXPOSE 137/udp 138/udp 139 445

COPY ["init.sh", "smb.conf", "./"]

ENTRYPOINT ["./init.sh"]
CMD ["smbd"]
