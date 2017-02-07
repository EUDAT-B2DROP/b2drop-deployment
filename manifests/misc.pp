# == Class: b2drop::misc
#
# do some common configuration, php hardening, selinux configuration, etc.
#
# === Parameters
#
# === Authors
#
# Benedikt von St. Vieth <b.von.st.vieth@fz-juelich.de>
# Sander Apweiler <sa.apweiler@fz-juelich.de>
#
# === Copyright
#
# Copyright 2015 EUDAT2020
#
# [*cron_run_interval*]
#   how often to run the cron
#   default: every 10 minutes
#
class b2drop::misc (
  $cron_run_interval = 10
){



  # manage tmp next to the owncloud dir for easier file uploads
  if ($::b2drop::manage_tmp) {
    validate_string($::b2drop::manage_tmp)
    file { $::b2drop::manage_tmp:
      ensure => directory,
      path   => $::b2drop::manage_tmp,
      mode   => '1777'
    }
    augeas { 'php.ini_tmp':
      context => '/files/etc/php.ini/PHP',
      notify  => Class['::apache'],
      changes => [
        "set upload_tmp_dir ${::b2drop::manage_tmp}",
        'set max_execution_time 360',
        'set max_input_time 360',
      ];
    }
  }

  #
  # mysql
  #
  if ! defined(Class['mysql::server']) {
    include ::mysql::server
  }
}
