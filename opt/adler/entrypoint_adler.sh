#!/bin/bash

# Load PHP-FPM environment variables
. /opt/bitnami/scripts/php-env.sh

# Load library
. /opt/bitnami/scripts/libphp.sh

# Set php.ini values from environment variables
! is_empty_value "$PHP_OUTPUT_BUFFERING" && info "Setting PHP output_buffering option" && php_conf_set output_buffering "$PHP_OUTPUT_BUFFERING" "$PHP_CONF_FILE"


# inject adler setup script
if ! grep "/opt/adler/setup.sh" /opt/bitnami/scripts/moodle/entrypoint.sh > /dev/null ; then
  echo "inject adler setup script"
  sed -i '/^exec "$@".*/i echo "starting adler setup script" && chown daemon /bitnami/moodle/config.php && su daemon -s /bin/bash -c "/opt/adler/setup.sh" && chown root /bitnami/moodle/config.php' /opt/bitnami/scripts/moodle/entrypoint.sh
fi


# continue with original entrypoint.sh
/opt/bitnami/scripts/moodle/entrypoint.sh "$@"


