# == Class: b2drop
#
# This class should provide the basic deployment of b2drop, with repos for b2drop theme and b2share bridge
# ldap link and other more complex settings are deployment specific.
# This module uses shoekstra-owncloud to setup owncloud repo, apache and mysql.
#
# Attention:
# If selinux is enabled, one has to execute the following commands:
# semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/owncloud/config'
# restorecon '/var/www/html/owncloud/config'
# semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/owncloud/apps'
# restorecon '/var/www/html/owncloud/apps'
# semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/owncloud/data'
# restorecon '/var/www/html/owncloud/data'
#
# === Parameters
#
# Document parameters here.
#
# [*autoupdate_theme*]
#   whether to autoupdate the theme via git repo
#
# [*autoupdate_plugin*]
#   whether to autoupdate the plugin via git repo
#
# === Examples
#
#  class { 'b2drop': }
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
  $autoupdate_theme    = false,
  $branch_theme        = 'master',
  $gitrepo_user_theme  = 'EUDAT-B2DROP',
  $autoupdate_plugin   = false,
  $branch_plugin       = 'master',
  $gitrepo_user_plugin = 'EUDAT-B2DROP',
){
  validate_bool($autoupdate_theme)
  validate_bool($autoupdate_plugin)

  class { '::owncloud':} ->
  class { '::b2drop::misc':} ->
  class { '::b2drop::repos':}

  if ! defined(Class['mysql::server']) {
    include ::mysql::server
  }
}
