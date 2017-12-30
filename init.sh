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
    exec smbd -F -S -s $VOL_CFG/smb.conf < /dev/null

elif [ "$1" == "adduser" ]; then
    if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        echo "You have to specify an username, an user id, and password"
        exit 1
    fi
    echo "Adding new user $2"
    USERDIR=$VOL_HOME/$2
    adduser -s /bin/false -h $USERDIR -u $3 -D $2
    echo -e "$4\n$4" | pdbedit -a -u $2 -t
    chmod -R 750 $USERDIR
    sed -i -E "s/$USER_GROUP:(.):([0-9]+):(.+)\$/$USER_GROUP:\1:\2:$2,\3/g" $UNIX_USERS/group
    sed -i -E "s/$USER_GROUP:(.):([0-9]+):\$/$USER_GROUP:\1:\2:$2/g" $UNIX_USERS/group

else
    echo "Executing command"
    exec "$@"
fi
