# == Class: b2drop::mysql
#
# setup database stuff
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
# [*nextcloud_password*]
#   Required: password to use for mysql database
#
# [*root_password*]
#   Required: password for root user
#
# [*monitoring_password*]
#   Required: password for monitorin user
#
# [*backup_password*]
#   Required: password for dump user
#
# [*backup_directory*]
#   Optional: where to place dumps, default '/usr/local/mysqldumps'
#
# [*backup_compress*]
#   Optional: whether to compress dumps, default false
#
# [*backup_max_allowed_packet*]
#   Optional: set max allowed packet size, default 1M
#
# [*max_connections*]
#   Optional: set the number of max allowed connections, default 151
#
# [*monitoring_host*]
#   Optional: which host to allow monitoring, default localhost
#
# [*db_directory*]
#   Optional: directory where the database is located, if it is unset the mysql
#   default will be used. Default is undef
#
# [*connect_timeout*]
#   Number of secconds waiting after an unsecsessfull handshake. Default 60
#
# [*wait_timeout*]
#   Number of seconds waiting for activity after a connection became inactive but not closed. Default 1000
#
class b2drop::mysql (
  $nextcloud_password,
  $root_password,
  $monitoring_password,
  $backup_password,
  $backup_directory = '/usr/local/mysqldumps',
  $backup_compress = false,
  $backup_max_allowed_packet = '1M',
  $max_connections = 151,
  $monitoring_host = 'localhost',
  $db_directory = undef,
  $connect_timeout = 60,
  $wait_timeout = 1000
){
    if $db_directory {
    validate_absolute_path($db_directory)
    file{ $db_directory:
      ensure => directory,
      owner  => $::mysql::params::mysql_group,
      group  => $::mysql::params::mysql_group,
    }

    $override_options = {
      'mysqld' => {
        'performance_schema' => 'on',
        'datadir'            => $db_directory,
        'max_connections'    => $max_connections,
        'connect_timeout'    => $connect_timeout,
        'wait_timeout'       => $wait_timeout,
      }
    }
  }else{
    $override_options = {
      'mysqld' => {
        'performance_schema' => 'on',
        'max_connections'    => $max_connections,
        'connect_timeout'    => $connect_timeout,
        'wait_timeout'       => $wait_timeout,
      }
    }
  }

  class { '::mysql::server':
    remove_default_accounts => true,
    root_password           => $root_password,
    override_options        => $override_options
  }
  class { '::mysql::server::monitor':
    mysql_monitor_username => 'monitoring',
    mysql_monitor_password => $monitoring_password,
    mysql_monitor_hostname => $monitoring_host
  }
  class { '::mysql::server::backup':
    backupuser       => 'backup',
    backuppassword   => $backup_password,
    backupdir        => $backup_directory,
    backupcompress   => false,
    maxallowedpacket => $backup_max_allowed_packet
  }

  mysql::db { 'nextcloud':
    user     => 'nextcloud',
    password => $nextcloud_password,
  }
}
