# Fixed values, do not change.
CONTAINER_ROOT=/var/www/html
REPO_ROOT=${TUGBOAT_ROOT}

# Configurable values, update to match the layout of this repo.
DRUPAL_ROOT=${REPO_ROOT}/web
SETTINGS_SOURCE=${REPO_ROOT}/dist/settings.php
SETTINGS_LOCAL_SOURCE=${REPO_ROOT}/dist/settings.tugboat.php
SITE_DIR=sites/default
FILES_DIR=${SITE_DIR}/files
CONFIG_DIR=${SITE_DIR}/sync

# Set the site creation method in tugboat-init, tugboat-update, and tugboat-build:
# createfromprofile:
DRUPAL_PROFILE=standard
DRUPAL_PROFILE_SETTINGS= --account-pass=admin --site-name='Demo Drupal 8 Site'
# createfromconfig:
CONFIG_SOURCE=${REPO_ROOT}/dist/sync/
# createfromdump:
DB_SOURCE=https://www.dropbox.com/s/xq64z3vphdfkwja/2018-03-30.sql.zip?dl=0
FILE_SOURCE=https://www.dropbox.com/s/z168vqbe2sadjc2/files.tar.gz?dl=0

packageinstallation:
	# Replace PHP 7.0 with PHP 7.1.
	apt-get install -y python-software-properties software-properties-common
	add-apt-repository -y ppa:ondrej/php
	apt-get update
	apt-get install -y \
		php7.1 \
		php7.1-mbstring \
		php7.1-mysql \
		php7.1-xml \
		php7.1-zip \
		php7.1-bcmath \
		php7.1-bz2 \
		php7.1-cli \
		php7.1-common \
		php7.1-curl \
		php7.1-dev \
		php7.1-gd \
		php7.1-intl \
		php7.1-json \
		php7.1-mbstring \
		php7.1-mcrypt \
		php7.1-mysql \
		php7.1-opcache \
		php7.1-phpdbg \
		php7.1-pspell \
		php7.1-readline \
		php7.1-recode \
		php7.1-soap \
		php7.1-sqlite3 \
		php7.1-tidy \
		php7.1-xml \
		php7.1-xsl \
		php7.1-zip \
		libapache2-mod-php7.1 \
		mysql-client \
		rsync
	a2enmod php7.1
	a2dismod php7.0
	echo "export PATH=\"${TUGBOAT_ROOT}/vendor/bin:${PATH}\"" >> /etc/profile.d/container_environment.sh
	. /etc/profile.d/container_environment.sh
	# Symlink the repository web root to the container web root.
	ln -sf ${DRUPAL_ROOT} ${CONTAINER_ROOT}
	# Clean up.
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

drupalsetup:
	# Drupal-specific configuration.
	composer install --no-ansi --no-interaction
	cp ${SETTINGS_SOURCE} ${CONTAINER_ROOT}/${SITE_DIR}/settings.php
	cp ${SETTINGS_LOCAL_SOURCE} ${CONTAINER_ROOT}/${SITE_DIR}/settings.local.php
	echo "\$$settings['hash_salt'] = '$$(openssl rand -hex 32)';" >> ${CONTAINER_ROOT}/${SITE_DIR}/settings.local.php
	echo "\$$config_directories['sync'] = '${CONFIG_DIR}';" >> ${CONTAINER_ROOT}/${SITE_DIR}/settings.local.php
	mkdir -p ${DRUPAL_ROOT}/${FILES_DIR}
	mkdir -p ${DRUPAL_ROOT}/${CONFIG_DIR}
	chgrp -R www-data ${DRUPAL_ROOT}/${SITE_DIR}
	chmod -R g+w ${DRUPAL_ROOT}/${FILES_DIR}
	chmod 2775 ${DRUPAL_ROOT}/${FILES_DIR}
	chmod -R g+w ${DRUPAL_ROOT}/${CONFIG_DIR}
	chmod 2775 ${DRUPAL_ROOT}/${CONFIG_DIR}
	mysql -h mysql -u tugboat -ptugboat -e "create database tugboat;"

createfromdump:
	# Create Tugboat site from a db dump and files from another site.
	curl -L ${DB_SOURCE} > /tmp/database.sql.gz
	zcat /tmp/database.sql.gz | mysql -h mysql -u tugboat -ptugboat tugboat
	curl -L ${FILE_SOURCE} > /tmp/files.tar.gz
	mkdir /tmp/files
	tar -C /tmp/files -zxf /tmp/files.tar.gz
	rsync -av --delete /tmp/files/ ${CONTAINER_ROOT}/${FILES_DIR}

createfromprofile:
	# Create empty Tugboat site from a profile.
	cd ${DRUPAL_ROOT}
	drush site-install ${DRUPAL_PROFILE} ${DRUPAL_PROFILE_SETTINGS} -y

createfromconfig:
	# Create Tugboat site from config export, requires https://www.drupal.org/project/config_export.
	# composer require "drupal/config_installer" --no-ansi --no-interaction
	rsync -av --delete ${CONFIG_SOURCE} ${CONTAINER_ROOT}/${CONFIG_DIR}
	cd ${DRUPAL_ROOT}
	drush site-install --verbose config_installer config_installer_sync_configure_form.sync_directory=${CONFIG_DIR} --yes 

build:
	drush -r ${CONTAINER_ROOT} cache-rebuild
	drush -r ${CONTAINER_ROOT} updb -y

cleanup:
	apt-get clean
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Swap in the desired method of creating the site:
# createfromdump, createfromprofile, or createfromconfig.
tugboat-init: packageinstallation drupalsetup createfromdump build cleanup
tugboat-update: createfromdump build cleanup
tugboat-build: build
