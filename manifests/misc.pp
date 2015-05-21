class b2drop::misc {
  # optimize php
  augeas { "php.ini":
    context => "/files/etc/php.ini/PHP",
    changes => [
      "set default_charset UTF-8",
      "set default_socket_timeout 300",
      "set upload_max_filesize 8G",
      "set post_max_size 8G"
    ];
  }

  # use cron instead of ajax.
  cron { 'owncloud':
    command => "php -f $::owncloud::params::documentroot/cron.php",
    user    => $::owncloud::params::www_user,
    minute  => '*/10'
  }

  # missing libs for centos
  $phpmodules = [ 'php-mysql']
  package { $phpmodules:
    ensure => 'installed',
  }

  #configure theme to be used

  file { 'b2drop_theme_config':
    path    => "${::owncloud::params::documentroot}/config/b2drop.config.php",
    content => '<?php
$CONFIG = array (
  \'theme\' => \'eudat\',
);
',
  }
}