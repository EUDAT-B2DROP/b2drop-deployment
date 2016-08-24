# == Class: b2drop::php
#
# optimize php, also add new php version to centos 7 if admin wants this to happen.
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
class b2drop::php (
){
  # configure additional package installation
  case $::osfamily {
    'RedHat': {
      if $::operatingsystem == 'CentOS' and $::operatingsystemmajrelease == '7'{
        $phpmodules = [ 'php70w-pecl-apcu', 'php70w-mysql' ]
        $gpg_path = '/etc/pki/rpm-gpg/RPM-GPG-KEY-webtatic-el7'
        yumrepo { 'webtatic':
          mirrorlist     => 'https://mirror.webtatic.com/yum/el7/$basearch/mirrorlist',
          baseurl        => 'https://repo.webtatic.com/yum/el7/$basearch/',
          failovermethod => 'priority',
          enabled        => '1',
          gpgcheck       => '1',
          gpgkey         => "file://${gpg_path}",
        }

        yumrepo { 'webtatic-debuginfo':
          mirrorlist     => 'https://mirror.webtatic.com/yum/el7/$basearch/debug/mirrorlist',
          baseurl        => 'https://repo.webtatic.com/yum/el7/$basearch/debug/',
          failovermethod => 'priority',
          enabled        => '0',
          gpgcheck       => '1',
          gpgkey         => "file://${gpg_path}",
        }

        yumrepo { 'webtatic-source':
          mirrorlist     => 'https://mirror.webtatic.com/yum/el7/SRPMS/mirrorlist',
          baseurl        => 'https://repo.webtatic.com/yum/el7/SRPMS/',
          failovermethod => 'priority',
          enabled        => '0',
          gpgcheck       => '1',
          gpgkey         => "file://${gpg_path}",
        }

        file { $gpg_path:
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => 'puppet:///modules/b2drop/RPM-GPG-KEY-webtatic-el7',
        }

        exec { 'import-webtatic-gpgkey':
          path      => '/bin:/usr/bin:/sbin:/usr/sbin',
          command   => "rpm --import ${gpg_path}",
          unless    => "rpm -q gpg-pubkey-$(echo $(gpg --throw-keyids < ${gpg_path}) | cut --characters=11-18 | tr '[A-Z]' '[a-z]')",
          require   => File[$gpg_path],
          logoutput => 'on_failure',
          before    => Yumrepo['webtatic','webtatic-debuginfo','webtatic-source'],
        }

        package { 'yum-plugin-replace':
          ensure  => 'installed',
          require => Exec['import-webtatic-gpgkey'],
          notify  => Exec['substitute-php-php70w'],
        }

        exec { 'substitute-php-php70w':
          refreshonly => true,
          path        => '/bin:/usr/bin:/sbin:/usr/sbin',
          command     => 'yum replace -y php-common
          --replace-with=php70w-common',
          require     => Package['yum-plugin-replace'],
        }
      }
      else {
        $phpmodules = [ 'php-pecl-apcu', 'php-mysql' ]
      }
    }
    'Debian': {
      $phpmodules = [ 'php5-apcu', 'php5-mysql' ]
    }
    default: {
      fail('Operating system not supported with this module')
    }
  }


  package {$phpmodules:
    ensure => 'installed',
  } ->
  augeas { 'php.ini':
    context => '/files/etc/php.ini/PHP',
    changes => [
      'set default_charset UTF-8',
      'set default_socket_timeout 300',
      'set upload_max_filesize 8G',
      'set post_max_size 8G',
      'set expose_php Off',
    ];
  } ->
  augeas { 'apcu.ini':
    context => '/files/etc/php.d/apcu.ini/.anon',
    changes => [
      'set apc.enable_cli 1',
    ];
  }

  file { 'owncloud_cache_config':
    path    => "${::owncloud::params::documentroot}/config/cache.config.php",
    content => '<?php
$CONFIG = array (
  \'memcache.local\' => \'\OC\Memcache\APCu\',
);
',
    require => Class['::owncloud'],
  }
}
