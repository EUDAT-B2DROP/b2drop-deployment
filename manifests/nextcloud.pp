# == Class: b2drop::nextcloud
#
# manage the git repositories inside of the nextcloud theme and app folder
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

  # cron
  if $::b2drop::manage_cron {
    cron { 'nextcloud':
      command => "php -f ${::b2drop::documentroot}/cron.php",
      user    => $::apache::params::user,
      minute  => "*/${cron_run_interval}"
    }
  }

  # select nextcloud theme
  file { 'b2drop_theme_config':
    path    => "${::b2drop::documentroot}/config/b2drop.config.php",
    content => "<?php
\$CONFIG = array (
  \'theme\' => \'b2drop\',
  \'lost_password_link\' => \'${::b2drop::reset_password_link}\'
);
",
    require => Vcsrepo["${::b2drop::documentroot}/themes/b2drop"]
  }

  package {'git':
    ensure   => 'installed'
  }

  # create some directories we refer to
  exec{ 'b2drop_create_docroot':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p ${::b2drop::documentroot}",
    unless  => "test -d ${::b2drop::documentroot}",
  } ->
  file {"${::b2drop::documentroot}":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  } ->
  file {"${::b2drop::documentroot}/apps":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }
  exec{ 'b2drop_create_datadirectory':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p ${::b2drop::datadirectory}",
    unless  => "test -d ${::b2drop::datadirectory}",
  } ->
  file {"${::b2drop::datadirectory}":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }

  # B2SHAREBRIDGE
  if $::b2drop::autoupdate_plugin {
    $plugin_ensure = 'latest'
  }
  else {
    $plugin_ensure = 'present'
  }

  vcsrepo { "${::b2drop::documentroot}/apps/b2sharebridge":
    ensure   => $plugin_ensure,
    revision => $::b2drop::branch_plugin,
    provider => git,
    source   => "https://github.com/${::b2drop::gitrepo_user_plugin}/b2sharebridge.git",
    user     => $::apache::params::user,
    group    => $::apache::params::group,
    require  => Package['git'],
  }

  # THEME
  if $::b2drop::autoupdate_theme {
    $theme_ensure = 'latest'
  }
  else {
    $theme_ensure = 'present'
  }
  file {"${::b2drop::documentroot}/themes":
    ensure => 'directory',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }

  vcsrepo { "${::b2drop::documentroot}/themes/b2drop":
    ensure   => $theme_ensure,
    revision => $::b2drop::branch_theme,
    provider => git,
    source   => "https://github.com/${::b2drop::gitrepo_user_theme}/b2drop-theme.git",
    user     => $::apache::params::user,
    group    => $::apache::params::group,
    require  => [ Package['git'], File["${::b2drop::documentroot}/themes"] ],
  }

  # logrotating
  logrotate::rule { 'nextcloud':
    rotate_every  => 'day',
    path          => "${::b2drop::datadirectory}/nextcloud.log",
    missingok     => true,
    ifempty       => true,
    compress      => true,
    delaycompress => true,
    rotate        => 14,
    create        => true,
    create_mode   => 640,
    create_owner  => $::apache::params::user,
    create_group  => $::apache::params::group,
    su            => true,
    su_owner      => $::apache::params::user,
    su_group      => $::apache::params::group,
  }
}
