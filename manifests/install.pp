# == Class: b2drop::install
#
# include new repositories for owncloud
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
class b2drop::install {

  if $::b2drop::manage_owncloud_repo {
    case $::operatingsystem {
      'CentOS': {
        include ::epel

        if $::operatingsystemmajrelease == '7' {
          yumrepo { 'ownCloud:community':
            name     => 'ownCloud_community',
            descr    => "Latest stable community release of ownCloud (CentOS_CentOS-${::operatingsystemmajrelease})",
            baseurl  => "https://download.owncloud.org/download/repositories/stable/CentOS_${::operatingsystemmajrelease}/",
            gpgcheck => 1,
            gpgkey   => "https://download.owncloud.org/download/repositories/stable/CentOS_${::operatingsystemmajrelease}/repodata/repomd.xml.key",
            enabled  => 1,
            before   => Package[$::owncloud::package_name],
          }
        }
      }
      default: {
      }
    }
  }

  package { $::owncloud::package_name:
    ensure => present,
  }
}
