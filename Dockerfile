FROM alpine:latest

WORKDIR /samba

RUN VERSION=4.7.3-r0 && \
    apk --no-cache add samba=${VERSION} && \
    VERSION=

ENV VOL_CFG=/samba/cfg

VOLUME ["${VOL_CFG}"]

EXPOSE 137/udp 138/udp 139 445

COPY ["init.sh", "smb.conf", "./"]

ENTRYPOINT ["./init.sh"]
CMD ["smbd"]