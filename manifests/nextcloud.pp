# == Class: b2drop::nextcloud
#
# manage cron, data dir and logrotating
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
class b2drop::nextcloud (
  $cron_run_interval = 10
) {

  # CRON
  if $::b2drop::manage_cron {
    cron { 'nextcloud':
      command => "php -f ${::b2drop::documentroot}/cron.php",
      user    => $::apache::params::user,
      minute  => "*/${cron_run_interval}"
    }
  }

  # APPS
  exec{ 'b2drop_create_docroot':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p ${::b2drop::documentroot}",
    unless  => "test -d ${::b2drop::documentroot}",
  }
  -> file {"${::b2drop::documentroot}":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }
  -> file {"${::b2drop::documentroot}/apps":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }

  # DATA
  exec{ 'b2drop_create_datadirectory':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p ${::b2drop::datadirectory}",
    unless  => "test -d ${::b2drop::datadirectory}",
  }
  -> file {"${::b2drop::datadirectory}":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }

  # LOGROTATING
  logrotate::rule { 'nextcloud':
    rotate_every  => 'day',
    path          => "${::b2drop::datadirectory}/nextcloud.log",
    missingok     => true,
    ifempty       => true,
    compress      => true,
    delaycompress => true,
    rotate        => 14,
    create        => true,
    create_mode   => '0640',
    create_owner  => $::apache::params::user,
    create_group  => $::apache::params::group,
    su            => true,
    su_owner      => $::apache::params::user,
    su_group      => $::apache::params::group,
  }
}
