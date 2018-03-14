packages:
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
	composer install --no-ansi --no-interaction
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	echo "export PATH=\"${TUGBOAT_ROOT}/vendor/bin:${PATH}\"" >> /etc/profile.d/container_environment.sh
	. /etc/profile.d/container_environment.sh

drupalconfig:
	# Symlink the Drupal root in the repository to the container web root.
	ln -sf ${TUGBOAT_ROOT}/web /var/www/html
	cp ${TUGBOAT_ROOT}/dist/settings.php /var/www/html/sites/default/settings.php
	cp ${TUGBOAT_ROOT}/dist/tugboat.settings.php /var/www/html/sites/default/settings.local.php
	echo "\$$settings['hash_salt'] = '$$(openssl rand -hex 32)';" >> /var/www/html/sites/default/settings.local.php
	echo "\$$settings['trusted_host_patterns'][] = '^$$TUGBOAT_PREVIEW_ID\.tugboat\.qa\$$';" >> /var/www/html/sites/default/settings.local.php
	mkdir -p web/sites/default/files
	chgrp -R www-data web/sites/default
	chmod -R g+w web/sites/default/files
	chmod 2775 web/sites/default/files

createdb:
	mysql -h mysql -u tugboat -ptugboat -e "create database tugboat;"

createsite:
	cd ${TUGBOAT_ROOT}/web
	drush site-install standard \
	 --account-mail=admin@example.com \
	 --account-name=admin \
	 --account-pass=admin \
	 --locale=en \
	 --site-name="Schema.org Metatag Demo Site" \
	 --site-mail=admin@example.com -y
	drush cim
	
importdb:
	curl -L "https://www.dropbox.com/s/ji41n0q14qgky9a/demo-drupal8-database.sql.gz?dl=0" > /tmp/database.sql.gz
	zcat /tmp/database.sql.gz | mysql -h mysql -u tugboat -ptugboat tugboat

importfiles:
	curl -L "https://www.dropbox.com/s/jveuu586eb49kho/demo-drupal8-files.tar.gz?dl=0" > /tmp/files.tar.gz
	tar -C /tmp -zxf /tmp/files.tar.gz
	rsync -av --delete /tmp/files/ /var/www/html/sites/default/files/

build:
	drush -r /var/www/html cache-rebuild
	drush -r /var/www/html updb -y

cleanup:
	apt-get clean
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

tugboat-init: packages createdb drupalconfig createsite build cleanup
tugboat-update: createsite build cleanup
tugboat-build: build
