# == Class: b2drop
#
# This class should provide the basic deployment of b2drop, with repos for b2drop theme and b2share bridge
# ldap link and other more complex settings are deployment specific.
# This module uses shoekstra-owncloud to setup owncloud repo, apache and mysql.
#
# === Parameters
#
# Document parameters here.
#
# [*autoupdate_theme*]
#   whether to autoupdate the theme via git repo
#
# [*branch_theme*]
#   branch to use for the theme, e.g. owncloud7, owncloud8...
#
# [*gitrepo_user_theme*]
#   the github user to which the repository for the theme belongs
#
# [*autoupdate_plugin*]
#   whether to autoupdate the plugin via git repo
#
# [*branch_plugin*]
#   branch to use for the plugin
#
# [*gitrepo_user_plugin*]
#   the github user to which the repository for the plugin belongs
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
