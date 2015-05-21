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
  vcsrepo { "${::owncloud::params::documentroot}/apps/eudat":
    ensure   => $plugin_ensure,
    revision => 'master',
    provider => git,
    source   => "https://github.com/${::b2drop::gitrepo_user_plugin}/b2share-bridge.git",
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

  vcsrepo { "${::owncloud::params::documentroot}/themes/eudat":
    ensure   => $theme_ensure,
    revision => 'master',
    provider => git,
    source   => "https://github.com/${::b2drop::gitrepo_user_theme}/b2drop-core.git",
    user     => "${::owncloud::params::www_user}",
    group    => "${::owncloud::params::www_group}",
    require  => [ Class['::owncloud'], Package['git'], File["${::owncloud::params::documentroot}/themes"] ],
  }
}