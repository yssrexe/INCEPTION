#!/bin/bash
set -e

echo "WordPress container initialization..."

if [ -z "$DB_NAME" ]; then echo "DB_NAME missing!"; exit 1; fi
if [ -z "$DB_USER" ]; then echo "DB_USER missing!"; exit 1; fi
if [ -z "$DB_PASSWORD" ]; then echo "DB_PASSWORD missing!"; exit 1; fi

DB_HOST="${DB_HOST:-mariadb}"
WP_PATH="/var/www/html"

mkdir -p "$WP_PATH"

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress core..."
    wp core download --path="$WP_PATH" --allow-root

    echo "Waiting for MariaDB to be ready..."
    until mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent; do
        sleep 1
    done

    wp config create \
        --path="$WP_PATH" \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --skip-check \
        --allow-root

    wp core install \
        --path="$WP_PATH" \
        --url="$WP_HTTPS_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_MAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_MAIL" \
        --user_pass="$WP_PASS" \
        --role=author \
        --allow-root
fi



chown -R www-data:www-data "$WP_PATH"

exec php-fpm8.2 -F
