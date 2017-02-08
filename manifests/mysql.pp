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
class b2drop::mysql (
  $nextcloud_password,
  $root_password,
  $monitoring_password,
  $backup_password,
  $backup_directory = '/usr/local/mysqldumps',
  $backup_compress = false,
  $monitoring_host = 'localhost'
){
  class { '::mysql::server':
    remove_default_accounts => true,
    root_password           => $root_password
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
