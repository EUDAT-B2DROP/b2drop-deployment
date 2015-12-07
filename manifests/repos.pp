# == Class: b2drop::repos
#
# manage the git repositories inside of the owncloud theme and app folder
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
class b2drop::repos {

  package {'git':
    ensure   => 'installed'
  }

  # manage plugin
  if $::b2drop::autoupdate_plugin {
    $plugin_ensure = 'latest'
  }
  else {
    $plugin_ensure = 'present'
  }

  vcsrepo { "${::owncloud::params::documentroot}/apps/b2share-bridge":
    ensure   => 'absent',
  }
  vcsrepo { "${::owncloud::params::documentroot}/apps/eudat":
    ensure   => 'absent',
  }

  vcsrepo { "${::owncloud::params::documentroot}/apps/b2sharebridge":
    ensure   => $plugin_ensure,
    revision => $::b2drop::branch_plugin,
    provider => git,
    source   => "https://github.com/${::b2drop::gitrepo_user_plugin}/b2sharebridge.git",
    user     => "${::owncloud::params::www_user}",
    group    => "${::owncloud::params::www_group}",
    require  => [ Class['::owncloud'], Package['git'] ],
  }

  # manage theme
  if $::b2drop::autoupdate_theme {
    $theme_ensure = 'latest'
  }
  else {
    $theme_ensure = 'present'
  }
  file {"${::owncloud::params::documentroot}/themes":
    ensure => 'directory',
    owner  => "${::owncloud::params::www_user}",
    group  => "${::owncloud::params::www_group}",
  }

  vcsrepo { "${::owncloud::params::documentroot}/themes/b2drop":
    ensure   => $theme_ensure,
    revision => $::b2drop::branch_theme,
    provider => git,
    source   => "https://github.com/${::b2drop::gitrepo_user_theme}/b2drop-core.git",
    user     => "${::owncloud::params::www_user}",
    group    => "${::owncloud::params::www_group}",
    require  => [ Class['::owncloud'], Package['git'], File["${::owncloud::params::documentroot}/themes"] ],
  }
}
