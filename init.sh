#!/bin/sh

set -e

SCRIPT_FILE=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_FILE")

UNIX_USERS=$VOL_CFG/unix
TDB_USERS=$VOL_CFG/tdb

if [ ! -f $VOL_CFG/smb.conf ]; then
    echo "Initializing samba config in volume"
    cp $SCRIPT_DIR/smb.conf $VOL_CFG/smb.conf
fi

if [ ! -f $UNIX_USERS/passwd ] || [ ! -f $UNIX_USERS/group ] || [ ! -f $UNIX_USERS/shadow ]; then
    echo "Initializing unix users in volume"
    mkdir -p $UNIX_USERS
    cp -f /etc/passwd $UNIX_USERS/
    cp -f /etc/group $UNIX_USERS/
    cp -f /etc/shadow $UNIX_USERS/
fi

echo "Using unix users from volume"
rm /etc/passwd
ln -s $UNIX_USERS/passwd /etc/passwd
rm /etc/group
ln -s $UNIX_USERS/group /etc/group
rm /etc/shadow
ln -s $UNIX_USERS/shadow /etc/shadow

echo "Using tdb users from volume"
rm -r /var/lib/samba/private
mkdir -p $TDB_USERS
ln -s $TDB_USERS /var/lib/samba/private

if [ "$1" == "smbd" ]; then
    echo "Starting samba server"
    smbd -FS -s $VOL_CFG/smb.conf
else
    echo "Executing command"
    exec "$@"
fi
