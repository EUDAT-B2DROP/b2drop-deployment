# == Class: b2drop::misc
#
# manage tmp directory if wished
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
class b2drop::misc (
){

  # manage tmp next to the data dir for easier file uploads (due to file mv)
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
}
