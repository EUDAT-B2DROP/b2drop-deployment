# == Class: b2drop::b2drop
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
class b2drop::b2drop (
) {

  package {'git':
    ensure   => 'installed'
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
    notify   => Exec['b2drop_b2sharebridge_upgrade']
  }
  # Continuously deploy b2sharebridge
  exec { 'b2drop_b2sharebridge_upgrade':
    refreshonly => true,
    cwd         => $::b2drop::documentroot,
    user        => $::apache::params::user,
    group       => $::apache::params::group,
    command     => "/usr/bin/php ${::b2drop::documentroot}/occ upgrade",
    require     => Vcsrepo["${::b2drop::documentroot}/apps/b2sharebridge"],
    logoutput   => true,
    before      => Exec['b2drop_turn_off_maintenance'],
    notify      => Exec['b2drop_turn_off_maintenance']
  }
  exec { 'b2drop_turn_off_maintenance':
    refreshonly => true,
    cwd         => $::b2drop::documentroot,
    user        => $::apache::params::user,
    group       => $::apache::params::group,
    command     => "/usr/bin/php ${::b2drop::documentroot}/occ maintenance:mode --off",
    require     => Exec['b2drop_b2sharebridge_upgrade'],
    logoutput   => true,
  }

  # THEME
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

  file {"${::b2drop::documentroot}/apps/notifications/img/notifications-new.svg":
    ensure => 'present',
    source => 'puppet:///modules/b2drop/notifications-new.svg',
    owner  => $::apache::params::user,
    group  => $::apache::params::group,
  }
}
