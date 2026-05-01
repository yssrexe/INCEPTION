#!/bin/bash
echo "mariaDB container initialization..."

# stop script if any command fails
set -e

# check if any env variable missing
if [ -z "$DB_USER" ]; then
    echo "DB_USER missing!"
    exit 1
fi
if [ -z "$DB_PASSWORD" ]; then
    echo "DB_PASSWORD missing!"
    exit 1
fi
if [ -z "$DB_NAME" ]; then
    echo "DB_NAME missing!"
    exit 1
fi

# start mariaDB in background and save pid
mysqld_safe &
pid=$!

# wait mariaDB to get ready
sleep 6

# create database, user for wordpress and give permission to user
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;

CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';

GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';

FLUSH PRIVILEGES;
EOF

# stop temporary server
kill $pid
wait $pid

# run mariaDB foreground as main process
exec mysqld_safe