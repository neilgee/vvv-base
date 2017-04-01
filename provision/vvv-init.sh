#!/usr/bin/env bash

# Change to the parent directory to run scripts.
cd "${VM_DIR}"

# Run composer
noroot composer install

# Make a database, if we don't already have one
echo -e "\nCreating database '${SITE_ESCAPED}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS \`${SITE_ESCAPED}\`"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON \`${SITE_ESCAPED}\`.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Maybe install WordPress
if ! $(noroot wp core is-installed); then
	echo "Installing WordPress..."
	echo ""

	WP_ADMIN_USER=`get_config_value admin_user 'admin_default'`
	WP_ADMIN_PASS=`get_config_value admin_password 'password_default'`
	WP_ADMIN_EMAIL=`get_config_value admin_email 'admin@localhost.dev'`
	WP_SITE_TITLE=`get_config_value title 'My Awesome Site'`
	WP_HOST=`get_primary_host`

	noroot wp core config --dbname="${SITE_ESCAPED}" --dbuser=wp --dbpass=wp --dbhost="localhost" --dbprefix=wp_ --locale=en_US --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', true );
define( 'SCRIPT_DEBUG', true );
define( 'JETPACK_DEV_DEBUG', true );
PHP

	noroot wp core install --url="${WP_HOST}" --title="${WP_SITE_TITLE}" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASS}" --admin_email="${WP_ADMIN_EMAIL}"
fi

# Return to the previous directory
cd -
