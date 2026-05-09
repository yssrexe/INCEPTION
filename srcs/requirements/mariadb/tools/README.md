# mariadb.sh README

## What this script does
This script initializes a MariaDB data directory inside a container. It validates required environment variables, starts MariaDB temporarily, creates the database and user, then shuts the temporary server down and starts MariaDB in the foreground as the container's main process.

## Required environment variables
- DB_USER: The database user to create.
- DB_PASSWORD: The password for DB_USER.
- DB_NAME: The database name to create and grant access to.

## Line-by-line explanation
| Line | Code | Explanation |
| --- | --- | --- |
| 1 | `#!/bin/bash` | Use the Bash shell to run this script. |
| 2 | `echo "mariaDB container initialization..."` | Print a startup message to the container logs. |
| 3 | *(blank)* | Visual separation for readability. |
| 4 | `# stop script if any command fails` | Comment describing the next command. |
| 5 | `set -e` | Exit immediately if any command returns a non-zero status. |
| 6 | *(blank)* | Visual separation for readability. |
| 7 | `# check if any env variable missing` | Comment describing the validation section. |
| 8 | `if [ -z "$DB_USER" ]; then` | If `DB_USER` is empty or unset, start the error branch. |
| 9 | `    echo "DB_USER missing!"` | Print a clear error message. |
| 10 | `    exit 1` | Exit the script with status 1 to signal failure. |
| 11 | `fi` | End of the `DB_USER` check. |
| 12 | `if [ -z "$DB_PASSWORD" ]; then` | If `DB_PASSWORD` is empty or unset, start the error branch. |
| 13 | `    echo "DB_PASSWORD missing!"` | Print a clear error message. |
| 14 | `    exit 1` | Exit the script with status 1 to signal failure. |
| 15 | `fi` | End of the `DB_PASSWORD` check. |
| 16 | `if [ -z "$DB_NAME" ]; then` | If `DB_NAME` is empty or unset, start the error branch. |
| 17 | `    echo "DB_NAME missing!"` | Print a clear error message. |
| 18 | `    exit 1` | Exit the script with status 1 to signal failure. |
| 19 | `fi` | End of the `DB_NAME` check. |
| 20 | *(blank)* | Visual separation for readability. |
| 21 | `# start mariaDB in background and save pid` | Comment describing the next two commands. |
| 22 | `mysqld_safe &` | Start MariaDB in the background with `mysqld_safe`. |
| 23 | `pid=$!` | Store the PID of the last background process (MariaDB) in `pid`. |
| 24 | *(blank)* | Visual separation for readability. |
| 25 | `# wait mariaDB to get ready` | Comment describing the wait. |
| 26 | `sleep 6` | Wait 6 seconds to give MariaDB time to start. |
| 27 | *(blank)* | Visual separation for readability. |
| 28 | `# create database, user for wordpress and give permission to user` | Comment describing the SQL setup. |
| 29 | `mysql <<EOF` | Start a here-document: send the following SQL lines to the `mysql` client. |
| 30 | `CREATE DATABASE IF NOT EXISTS $DB_NAME;` | Create the database if it does not already exist. |
| 31 | *(blank)* | Separation inside the SQL for readability. |
| 32 | `CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';` | Create the user (any host) if it does not exist, with the provided password. |
| 33 | *(blank)* | Separation inside the SQL for readability. |
| 34 | `GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';` | Grant full access on the database to the user. |
| 35 | *(blank)* | Separation inside the SQL for readability. |
| 36 | `FLUSH PRIVILEGES;` | Reload privilege tables so the changes take effect. |
| 37 | `EOF` | End the here-document; the `mysql` client executes the SQL. |
| 38 | *(blank)* | Visual separation for readability. |
| 39 | `# stop temporary server` | Comment describing the shutdown of the temporary server. |
| 40 | `kill $pid` | Send a termination signal to the temporary MariaDB process. |
| 41 | `wait $pid` | Wait for the MariaDB process to fully exit. |
| 42 | *(blank)* | Visual separation for readability. |
| 43 | `# run mariaDB foreground as main process` | Comment describing the final start. |
| 44 | `exec mysqld_safe` | Replace the shell with MariaDB so it runs in the foreground as PID 1. |

## Notes on the `if` conditions
Each `if [ -z "$VAR" ]; then` test checks whether the variable is empty or not set. If it is empty, the script prints a message and exits with status `1`. This prevents MariaDB from starting with missing configuration values.
