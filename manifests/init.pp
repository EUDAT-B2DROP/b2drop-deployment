# == Class: b2drop
#
# This class should provide the basic deployment of b2drop, with repos for
# b2drop theme and b2share bridge.
#
# ldap deployment and other more complex settings are deployment specific,
# therefore not managed within this module.
#
# owncloud:
# This module uses shoekstra-owncloud to setup owncloud, apache and mysql.
# Currently we manage the owncloud repo by our own, because shoekstra is
# referring to a outdated repo. We will use his module
#
# php:
# A php7 repo is managed using b2drop::php.
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
# [*manage_owncloud_repo*]
#   whether to manage owncloud repository
#
# [*manage_owncloud_cron*]
#   whether to manage owncloud cron or use aj
#
# [*manage_php*]
#   whether to manage php installation and configurtion
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
  $autoupdate_theme     = false,
  $branch_theme         = 'master',
  $gitrepo_user_theme   = 'EUDAT-B2DROP',
  $autoupdate_plugin    = false,
  $branch_plugin        = 'master',
  $gitrepo_user_plugin  = 'EUDAT-B2DROP',
  $manage_owncloud_repo = true,
  $manage_owncloud_cron = true,
  $manage_php           = true,
){
  validate_bool($autoupdate_theme)
  validate_bool($autoupdate_plugin)
  validate_bool($manage_owncloud_repo)
  validate_bool($manage_owncloud_cron)
  validate_bool($manage_php)

  if $manage_php {
    include ::b2drop::php
    $owncloud_module_manage_php = !$manage_php
  }

  class { '::owncloud':
    manage_phpmysql => $owncloud_module_manage_php
  }
  include ::b2drop::misc
  include ::b2drop::repos


}
