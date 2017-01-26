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
  #
  # owncloud cron
  #
  if $::b2drop::manage_owncloud_cron {
    cron { 'owncloud':
      command => "php -f ${::owncloud::params::documentroot}/cron.php",
      user    => $::owncloud::params::www_user,
      minute  => "*/${cron_run_interval}"
    }
  }
  #
  # configure theme to be used
  #
  file { 'b2drop_theme_config':
    path    => "${::owncloud::params::documentroot}/config/b2drop.config.php",
    content => "<?php
\$CONFIG = array (
  \'theme\' => \'b2drop\',
  \'lost_password_link\' => \'${::b2drop::reset_password_link}\'
);
",
  }

  #
  # manage tmp next to the owncloud dir for easier file uploads
  #
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

  #
  # selinux
  #
  if $::osfamily == 'RedHat' {
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
    if $::b2drop::manage_tmp {
      selinux::fcontext{ 'custom_tmp_context':
        context  => 'tmp_t',
        pathname => $::b2drop::manage_tmp,
        notify   => Exec['set_custom_tmp_context'],
      }
      exec{ 'set_custom_tmp_context':
        command     => "/sbin/restorecon -Rv ${::b2drop::manage_tmp}",
        refreshonly => true,
        require     => File[$::b2drop::manage_tmp]
      }
    }
  }
}
