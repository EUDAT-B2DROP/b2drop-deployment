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
# [*password*]
#   required: password to use for mysql database
#
class b2drop::mysql (
  $password,
){
  include ::mysql::server
  include ::mysql::server::account_security
  include ::mysql::server::monitor
  include ::mysql::server::backup

  mysql::db { 'nextcloud':
    user     => 'nextcloud',
    password => $password,
  }
}
