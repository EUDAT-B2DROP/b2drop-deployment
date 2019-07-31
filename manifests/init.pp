# == Class: b2drop
#
# This class should provide the basic deployment of b2drop, with repos for
# b2drop theme and b2share bridge.
#
# ldap deployment and other more complex settings are deployment specific,
# therefore not managed within this module.
#
#
# php:
# A php7 repo is managed using b2drop::php.
#
# === Parameters
#
# Document parameters here.
#
# [*apache_ssl_chain*]
#   Required: ssl chain to use
#
# [*apache_ssl_key*]
#   Required: ssl key to use
#
# [*apache_ssl_cert*]
#   Required: ssl cert to use
#
# [*mysql_nextcloud_password*]
#   Required: password to use for mysql database
#
# [*mysql_root_password*]
#   Required: password for root user
#
# [*mysql_monitoring_password*]
#   Required: password for monitorin user
#
# [*mysql_backup_password*]
#   Required: password for dump user
#
# [*apache_bind_interface*]
#   Optional: which ip interface to use, defaults to em1. e.g. eth0!
#
# [*apache_servername*]
#   Optional: which servername to use, defaults to b2drop.eudat.eu
#
# [*autoupdate_theme*]
#   Optional: whether to autoupdate the theme via git repo
#
# [*branch_theme*]
#   Optional: branch to use for the theme, e.g. owncloud7, owncloud8...
#
# [*gitrepo_user_theme*]
#   Optional: the github user to which the repository for the theme belongs
#
# [*autoupdate_plugin*]
#   Optional: whether to autoupdate the plugin via git repo
#
# [*branch_plugin*]
#   Optional: branch to use for the plugin
#
# [*gitrepo_user_plugin*]
#   Optional: the github user to which the repository for the plugin belongs
#
# [*documentroot*]
#   Optional: where is nextcloud installed to, defaults to /var/www/nextcloud
#
# [*datadirectory*]
#   Optional: where are the data, defaults to $documentroot/data
#
# [*manage_cron*]
#   Optional: whether to manage nextcloud cron or use aj
#
# [*manage_php*]
#   Optional: whether to manage php installation and configurtion
#
# [*manage_selinux*]
#   Optional: whether to manage some selinux rules
#
# [*manage_tmp*]
#   Optional: whether to manage a custom php directory for file uploads
#
# [*mysql_backup_directory*]
#   Optional: where to place dumps, default '/usr/local/mysqldumps'
#
# [*mysql_backup_compress*]
#   Optional: whether to compress dumps, default false
#
# [*mysql_monitoring_host*]
#   Optional: which host to allow monitoring, default localhost
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
class b2drop (
  $apache_ssl_chain,
  $apache_ssl_key,
  $apache_ssl_cert,
  $mysql_nextcloud_password,
  $mysql_root_password,
  $mysql_monitoring_password,
  $mysql_backup_password,
  $apache_bind_interface  = 'em1',
  $apache_servername      = 'b2drop.eudat.eu',
  $autoupdate_theme       = false,
  $branch_theme           = 'master',
  $gitrepo_user_theme     = 'EUDAT-B2DROP',
  $autoupdate_plugin      = false,
  $branch_plugin          = 'master',
  $gitrepo_user_plugin    = 'EUDAT-B2DROP',
  $documentroot           = '/var/www/nextcloud',
  $datadirectory          = "${documentroot}/data",
  $manage_cron            = true,
  $manage_php             = true,
  $manage_selinux         = true,
  $manage_tmp             = false,
  $mysql_backup_directory = '/usr/local/mysqldumps',
  $mysql_backup_compress  = false,
  $mysql_monitoring_host  = 'localhost',
){
  validate_bool($autoupdate_theme)
  validate_bool($autoupdate_plugin)
  validate_bool($manage_cron)
  validate_bool($manage_php)
  validate_bool($manage_selinux)

  if $manage_php {
    include ::b2drop::php
  }
  if $manage_selinux {
    include ::b2drop::selinux
  }

  class { '::b2drop::apache':
    ssl_cert       => $apache_ssl_cert,
    ssl_chain      => $apache_ssl_chain,
    ssl_key        => $apache_ssl_key,
    bind_interface => $apache_bind_interface,
    servername     => $apache_servername
  }
  class { '::b2drop::mysql':
    nextcloud_password  => $mysql_nextcloud_password,
    root_password       => $mysql_root_password,
    monitoring_password => $mysql_monitoring_password,
    backup_password     => $mysql_backup_password,
    backup_directory    => $mysql_backup_directory,
    backup_compress     => $mysql_backup_compress,
    monitoring_host     => $mysql_monitoring_host
  }

  include ::b2drop::misc
  include ::b2drop::nextcloud
  include ::b2drop::b2drop
}
