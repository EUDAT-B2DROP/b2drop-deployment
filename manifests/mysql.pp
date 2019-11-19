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
# [*monitoring_host*]
#   Optional: which host to allow monitoring, default localhost
#
# [*db_directory*]
#   Optional: directory where the database is located, if it is unset the mysql
#   default will be used. Default is undef
#
class b2drop::mysql (
  $nextcloud_password,
  $root_password,
  $monitoring_password,
  $backup_password,
  $backup_directory = '/usr/local/mysqldumps',
  $backup_compress = false,
  $monitoring_host = 'localhost',
  $db_directory = undef
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
        'datadir'            => "'${db_directory}'",
      }
    }
  }else{
    $override_options = {
      'mysqld' => {
        'performance_schema' => 'on',
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
    backupuser     => 'backup',
    backuppassword => $backup_password,
    backupdir      => $backup_directory,
    backupcompress => false
  }

  mysql::db { 'nextcloud':
    user     => 'nextcloud',
    password => $nextcloud_password,
  }
}
