# wordpress.sh README

## What this script does
This script bootstraps a WordPress install inside the container. It validates the database environment variables, downloads WordPress if missing, waits for MariaDB to accept connections, generates `wp-config.php`, installs the site, optionally creates a secondary user, fixes file ownership, and then starts PHP-FPM in the foreground.

## Required environment variables
- DB_NAME: The database name to connect to.
- DB_USER: The database user for WordPress.
- DB_PASSWORD: The password for DB_USER.

## Optional environment variables
- DB_HOST: Database host (defaults to `mariadb`).
- WP_HTTPS_URL: Site URL used for WordPress install (overrides DOMAIN).
- DOMAIN: Used to build a fallback URL `http://<DOMAIN>` when WP_HTTPS_URL is empty.
- WP_TITLE: WordPress site title (default: `Inception WordPress`).
- WP_ADMIN_USER: Admin username (default: `admin`).
- WP_ADMIN_PASS: Admin password (default: `admin123`).
- WP_ADMIN_MAIL: Admin email (default: `admin@example.com`).
- WP_USER: Optional secondary user to create.
- WP_MAIL: Email for the secondary user.
- WP_PASS: Password for the secondary user.

## Line-by-line explanation
| Line | Code | Explanation |
| --- | --- | --- |
| 1 | `#!/bin/bash` | Use the Bash shell to run this script. |
| 2 | `set -e` | Exit immediately if any command fails. |
| 3 | *(blank)* | Visual separation for readability. |
| 4 | `echo "WordPress container initialization..."` | Print a startup message to the container logs. |
| 5 | *(blank)* | Visual separation for readability. |
| 6 | `if [ -z "$DB_NAME" ]; then echo "DB_NAME missing!"; exit 1; fi` | Validate that DB_NAME is set; stop if missing. |
| 7 | `if [ -z "$DB_USER" ]; then echo "DB_USER missing!"; exit 1; fi` | Validate that DB_USER is set; stop if missing. |
| 8 | `if [ -z "$DB_PASSWORD" ]; then echo "DB_PASSWORD missing!"; exit 1; fi` | Validate that DB_PASSWORD is set; stop if missing. |
| 9 | *(blank)* | Visual separation for readability. |
| 10 | `DB_HOST="${DB_HOST:-mariadb}"` | Set DB_HOST default to `mariadb` if not provided. |
| 11 | `WP_PATH="/var/www/html"` | Define the WordPress install directory. |
| 12 | *(blank)* | Visual separation for readability. |
| 13 | `mkdir -p "$WP_PATH"` | Ensure the WordPress directory exists. |
| 14 | *(blank)* | Visual separation for readability. |
| 15 | `if [ ! -f "$WP_PATH/wp-config.php" ]; then` | Only bootstrap WordPress if config does not exist yet. |
| 16 | `echo "Downloading WordPress core..."` | Log the WordPress download step. |
| 17 | `wp core download --path="$WP_PATH" --allow-root` | Download WordPress core files via WP-CLI. |
| 18 | *(blank)* | Visual separation for readability. |
| 19 | `echo "Waiting for MariaDB to be ready..."` | Log the DB wait step. |
| 20 | `until mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent; do` | Poll MariaDB until it responds. |
| 21 | `sleep 1` | Wait 1 second between checks. |
| 22 | `done` | End of the wait loop. |
| 23 | *(blank)* | Visual separation for readability. |
| 24 | `wp config create \` | Begin creating `wp-config.php` using WP-CLI. |
| 25 | `--path="$WP_PATH" \` | Target the WordPress directory. |
| 26 | `--dbname="$DB_NAME" \` | Set the database name. |
| 27 | `--dbuser="$DB_USER" \` | Set the database user. |
| 28 | `--dbpass="$DB_PASSWORD" \` | Set the database password. |
| 29 | `--dbhost="$DB_HOST" \` | Set the database host. |
| 30 | `--skip-check \` | Skip DB connection check to avoid early failure. |
| 31 | `--allow-root` | Allow WP-CLI to run as root inside the container. |
| 32 | *(blank)* | Visual separation for readability. |
| 33 | `SITE_URL="$WP_HTTPS_URL"` | Start with WP_HTTPS_URL as the site URL. |
| 34 | `if [ -z "$SITE_URL" ]; then` | If WP_HTTPS_URL is empty, use DOMAIN instead. |
| 35 | `DOMAIN_VALUE="${DOMAIN:-localhost}"` | Default DOMAIN to `localhost` when not set. |
| 36 | `SITE_URL="http://${DOMAIN_VALUE}"` | Build the fallback URL from DOMAIN. |
| 37 | `fi` | End of the fallback URL selection. |
| 38 | *(blank)* | Visual separation for readability. |
| 39 | `WP_TITLE_VALUE="${WP_TITLE:-Inception WordPress}"` | Set the site title with a default. |
| 40 | `WP_ADMIN_USER_VALUE="${WP_ADMIN_USER:-admin}"` | Set the admin username with a default. |
| 41 | `WP_ADMIN_PASS_VALUE="${WP_ADMIN_PASS:-admin123}"` | Set the admin password with a default. |
| 42 | `WP_ADMIN_MAIL_VALUE="${WP_ADMIN_MAIL:-admin@example.com}"` | Set the admin email with a default. |
| 43 | *(blank)* | Visual separation for readability. |
| 44 | `wp core install \` | Begin WordPress installation. |
| 45 | `--path="$WP_PATH" \` | Target the WordPress directory. |
| 46 | `--url="$SITE_URL" \` | Set the site URL. |
| 47 | `--title="$WP_TITLE_VALUE" \` | Set the site title. |
| 48 | `--admin_user="$WP_ADMIN_USER_VALUE" \` | Set the admin username. |
| 49 | `--admin_password="$WP_ADMIN_PASS_VALUE" \` | Set the admin password. |
| 50 | `--admin_email="$WP_ADMIN_MAIL_VALUE" \` | Set the admin email. |
| 51 | `--skip-email \` | Do not send an email after install. |
| 52 | `--allow-root` | Allow WP-CLI to run as root inside the container. |
| 53 | *(blank)* | Visual separation for readability. |
| 54 | `if [ -n "$WP_USER" ] && [ -n "$WP_MAIL" ] && [ -n "$WP_PASS" ]; then` | Only create a secondary user when all fields are present. |
| 55 | `wp user create "$WP_USER" "$WP_MAIL" \` | Create the secondary user in WordPress. |
| 56 | `--user_pass="$WP_PASS" \` | Set the secondary user's password. |
| 57 | `--role=author \` | Assign the author role to the secondary user. |
| 58 | `--allow-root` | Allow WP-CLI to run as root inside the container. |
| 59 | `fi` | End of secondary user creation. |
| 60 | `fi` | End of first-run bootstrap. |
| 61 | *(blank)* | Visual separation for readability. |
| 62 | `chown -R www-data:www-data "$WP_PATH"` | Ensure WordPress files are owned by www-data. |
| 63 | *(blank)* | Visual separation for readability. |
| 64 | `exec php-fpm8.2 -F` | Start PHP-FPM in the foreground as PID 1. |

## Notes on idempotency
The script only performs the WordPress download and installation steps when `wp-config.php` does not exist, so restarts do not reinitialize the site.