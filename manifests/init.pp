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
# [*documentroot*]
#   where is nextcloud installed to, defaults to /var/www/nextcloud
#
# [*datadirectory*]
#   where are the data, defaults to $documentroot/data
#
# [*manage_cron*]
#   whether to manage nextcloud cron or use aj
#
# [*manage_php*]
#   whether to manage php installation and configurtion
#
# [*manage_selinux*]
#   whether to manage some selinux rules
#
# [*manage_tmp*]
#   whether to manage a custom php directory for file uploads
#
# [*reset_password_link*]
#   link that prompted when user types in wrong password
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
  $documentroot         = '/var/www/nextcloud',
  $datadirectory        = "${documentroot}/data",
  $manage_cron          = true,
  $manage_php           = true,
  $manage_selinux       = true,
  $manage_tmp           = false,
  $reset_password_link  = 'https://b2drop.eudat.eu/pwm/public/ForgottenPassword'
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

  include ::b2drop::apache
  include ::b2drop::misc
  include ::b2drop::mysql
  include ::b2drop::nextcloud
}
