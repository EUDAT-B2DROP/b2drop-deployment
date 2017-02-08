# == Class: b2drop::apache
#
# optimize php, also add new php version to centos 7 if admin wants this to happen.
#
# === Parameters
#
# [*ssl_chain*]
#   Required: ssl chain to use
#
# [*ssl_key*]
#   Required: ssl key to use
#
# [*ssl_cert*]
#   Required: ssl cert to use
#
# [*bind_interface*]
#   Optional: which ip interface to use, defaults to em1. e.g. eth0!
#
# [*servername*]
#   Optional: which servername to use, defaults to b2drop.eudat.eu
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
class b2drop::apache (
  $ssl_chain,
  $ssl_key,
  $ssl_cert,
  $bind_interface = 'em1',
  $servername     = 'b2drop.eudat.eu',
) {
  # because binding is on docker hosts sometimes...more complex
  if $bind_interface in split($::interfaces, ',') {
    $bind_ip = inline_template("<%= @ipaddress_${bind_interface} %>")
  } else {
    fail("The interface ${bind_interface} is not available, erroring!")
  }

  class { '::apache':
    default_mods        => [ 'env', 'dav', 'dir', 'headers', 'rewrite', 'proxy',
      'proxy_ajp'],
    default_confd_files => false,
    default_vhost       => false,
    mpm_module          => 'prefork',
    purge_configs       => true,
    purge_vhost_dir     => true,
  }

  apache::vhost { 'b2drop-eudat-http':
    ip            => $bind_ip,
    servername    => $servername,
    port          => 80,
    docroot       => $::b2drop::documentroot,
    docroot_owner => $::apache::params::user,
    docroot_group => $::apache::params::group,
    rewrites      => [
      {
        comment      => 'redirect non-SSL traffic to SSL site',
        rewrite_cond => ['%{HTTPS} off'],
        rewrite_rule => ['(.*) https://%{HTTP_HOST}%{REQUEST_URI}'],
      }
    ]
  }

  apache::vhost { 'b2drop-eudat-https':
    ip            => $bind_ip,
    servername    => $servername,
    port          => 443,
    docroot       => $::b2drop::documentroot,
    docroot_owner => $::apache::params::user,
    docroot_group => $::apache::params::group,
    directories   => {
      path            => '/var/www/nextcloud',
      options         => ['Indexes', 'FollowSymLinks', 'MultiViews'],
      allow_override  => 'All',
      custom_fragment => 'Dav Off',
      require         => 'all granted',
    },
    ssl           => true,
    ssl_cert      => $ssl_cert,
    ssl_chain     => $ssl_chain,
    ssl_key       => $ssl_key,
    headers       => [
      "always set Strict-Transport-Security \"max-age=15768000; \
includeSubDomains; preload\"",
      'always append X-Frame-Options SAMEORIGIN'
    ],
    proxy_pass    => [
      {
        'path' => '/pwm',
        'url'  => 'ajp://localhost:8009/pwm'
      }
    ]
  }

  # some php stuff
  ::apache::mod { 'php':
    id  => 'php7_module',
    lib => 'libphp7.so',
  }
  file { "${::apache::mod_dir}/php.conf":
    owner   => 'root',
    group   => $::apache::params::root_group,
    mode    => '0644',
    content => '
#
# Cause the PHP interpreter to handle files with a .php extension.
#
AddHandler php7-script .php
AddType text/html .php

#
# Add index.php to the list of files that will be served as directory
# indexes.
#
DirectoryIndex index.php

#
# Uncomment the following line to allow PHP to pretty-print .phps
# files as PHP source code:
#
#AddType application/x-httpd-php-source .phps

#
# Apache specific PHP configuration options
# those can be override in each configured vhost
#
php_value session.save_handler "files"
php_value session.save_path    "/var/lib/php/session"
php_value soap.wsdl_cache_dir  "/var/lib/php/wsdlcache"
'
  }
}
