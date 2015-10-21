# == Class: b2drop::misc
#
# do some common configuration, php hardening, selinux configuration, etc.
#
# === Parameters
#
# [*manage_php*]
#  if we are on CentOS7, manage php5.6 installation.
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
  $manage_php = false
){
  # manage php

  # optimize php
  augeas { 'php.ini':
    context => '/files/etc/php.ini/PHP',
    changes => [
      'set default_charset UTF-8',
      'set default_socket_timeout 300',
      'set upload_max_filesize 8G',
      'set post_max_size 8G',
      'set expose_php Off'
    ];
  }

  # configure additional package installation
  case $::osfamily {
    'RedHat': {
      if $manage_php {
        $phpmodules = [ 'php56w-pecl-apcu', 'php56w-pecl-memcached', 'php56w-mysql' ]
      }
      else {
        $phpmodules = [ 'php-pecl-apcu', 'php-pecl-memcached', 'php-mysql' ]
      }
    }
    'Debian': {
      $phpmodules = [ 'php5-apcu', 'php5-memcached', 'php5-mysql' ]
    }
    default: {
      fail('Operating system not supported with this module')
    }
  }


  package { $phpmodules:
    ensure => 'installed',
  }

  class { '::memcached':
    listen_ip => $::ipaddress_lo
  }

  file { 'owncloud_memcache_config':
    path    => "${::owncloud::params::documentroot}/config/cache.config.php",
    content => '<?php
$CONFIG = array (
  \'memcache.local\' => \'\OC\Memcache\APCu\',
  \'memcache.distributed\' =>\'\OC\Memcache\Memcached\',
  \'memcached_servers\' => array(
    array(\'localhost\', 11211),
    ),
);
',
  }

  # use cron instead of ajax.
  cron { 'owncloud':
    command => "php -f ${::owncloud::params::documentroot}/cron.php",
    user    => $::owncloud::params::www_user,
    minute  => '*/10'
  }

  #configure theme to be used
  file { 'b2drop_theme_config':
    path    => "${::owncloud::params::documentroot}/config/b2drop.config.php",
    content => '<?php
$CONFIG = array (
  \'theme\' => \'b2drop\',
);
',
  }

  if $::osfamily == RedHat {
    # missing php lib
    $phpmodules = [ 'php-mysql']
    package { $phpmodules:
      ensure => 'installed',
    }
    #selinux onfiguration
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
