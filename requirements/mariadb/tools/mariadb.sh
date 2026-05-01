#!/bin/bash

set -e

echo "Starting MariaDB setup..."

# Initialize MariaDB system tables if the volume is empty
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     echo "Installing MariaDB system tables..."
#     chown -R mysql:mysql /var/lib/mysql
#     mariadb-install-db --user=mysql --datadir=/var/lib/mysql
# fi

if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
    echo "Initializing database..."

    mysqld_safe &

    while ! mysqladmin ping --silent; do
        sleep 1
    done

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS testdb;

CREATE USER IF NOT EXISTS 'testuser'@'%' IDENTIFIED BY '1234';

GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '123345';

FLUSH PRIVILEGES;
EOF

mysqladmin -u root -p123345 shutdown

fi

echo "MariaDB setup completed. Starting MariaDB server..."

exec mysqld_safe