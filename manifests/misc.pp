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
class b2drop::misc {
  #
  # owncloud cron
  #
  if $::b2drop::manage_owncloud_cron {
    cron { 'owncloud':
      command => "php -f ${::owncloud::params::documentroot}/cron.php",
      user    => $::owncloud::params::www_user,
      minute  => '*/10'
    }
  }
  #
  # configure theme to be used
  #
  file { 'b2drop_theme_config':
    path    => "${::owncloud::params::documentroot}/config/b2drop.config.php",
    content => '<?php
$CONFIG = array (
  \'theme\' => \'b2drop\',
);
',
  }

  #
  # manage tmp next to the owncloud dir for easier file uploads
  #
  if ($::b2drop::manage_tmp and validate_string($::b2drop::manage_tmp)) {
    file { $::b2drop::manage_tmp:
      path   => $::b2drop::manage_tmp,
      ensure => directory,
      mode   => '1777'
    }
    augeas { 'php.ini_tmp':
      context => '/files/etc/php.ini/PHP',
      notify  => Class['::apache'],
      changes => [
        "set upload_tmp_dir ${::b2drop::manage_tmp}",
      ];
    }
  }

  #
  # mysql
  #
  if ! defined(Class['mysql::server']) {
    include ::mysql::server
  }

  #
  # selinux
  #
  if $::osfamily == RedHat {
    selinux::fcontext{ 'owncloud_docroot_httpd_context':
      context  => 'httpd_sys_rw_content_t',
      pathname => "${::owncloud::datadirectory}(/.*)?",
      notify   => Exec['owncloud_set_docroot_httpd_context'],
      require  => File["${::owncloud::datadirectory}"]
    }
    exec{ 'owncloud_set_docroot_httpd_context':
      command     => "/sbin/restorecon -Rv ${::owncloud::datadirectory}",
      refreshonly => true,
      require     => File["${::owncloud::datadirectory}"]
    }
    selinux::fcontext{ 'owncloud_config_httpd_context':
      context  => 'httpd_sys_rw_content_t',
      pathname => "${::owncloud::params::documentroot}/config(/.*)?",
      notify   => Exec['owncloud_set_config_httpd_context'],
      require  => File["${::owncloud::params::documentroot}"]
    }
    exec{ 'owncloud_set_config_httpd_context':
      command     => "/sbin/restorecon -Rv ${::owncloud::params::documentroot}/config",
      refreshonly => true,
      require     => File["${::owncloud::params::documentroot}"]
    }
    selinux::fcontext{ 'owncloud_apps_httpd_context':
      context  => 'httpd_sys_rw_content_t',
      pathname => "${::owncloud::params::documentroot}/apps(/.*)?",
      notify   => Exec['owncloud_set_apps_httpd_context'],
      require  => File["${::owncloud::params::documentroot}"]
    }
    exec{ 'owncloud_set_apps_httpd_context':
      command     => "/sbin/restorecon -Rv ${::owncloud::params::documentroot}/apps",
      refreshonly => true,
      require     => File["${::owncloud::params::documentroot}"]
    }
  }
}
