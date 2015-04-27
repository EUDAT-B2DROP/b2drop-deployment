# == Class: b2drop
#
# This class should provide the basic deployment of b2drop, with repos for b2drop theme and b2share bridge
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
  $autoupdate_theme  = false,
  $gitrepo_user_theme = 'EUDAT-B2DROP',
  $autoupdate_plugin = false,
  $gitrepo_user_plugin = 'EUDAT-B2DROP',
){
  validate_bool($autoupdate_theme)
  validate_bool($autoupdate_plugin)

  class { '::owncloud':} ->
  class { '::b2drop::repos':}
}
