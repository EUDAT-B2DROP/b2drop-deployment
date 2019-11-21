# == Class: b2drop::selinux
#
# manage some selinux rules for directories used by nextcloud
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
class b2drop::selinux (
){
  selinux::fcontext{ 'nextcloud_datadircontent_httpd_context':
    context  => 'httpd_sys_rw_content_t',
    pathname => "${::b2drop::datadirectory}(/.*)?",
    notify   => Exec['nextcloud_set_datadircontent_httpd_context'],
    require  => File["${::b2drop::datadirectory}"]
  }
  exec{ 'nextcloud_set_datadircontent_httpd_context':
    command     => "/sbin/restorecon -Rv ${::b2drop::datadirectory}",
    refreshonly => true,
    require     => File["${b2drop::datadirectory}"]
  }
  selinux::fcontext{ 'nextcloud_config_httpd_context':
    context  => 'httpd_sys_rw_content_t',
    pathname => "${::b2drop::documentroot}/config(/.*)?",
    notify   => Exec['nextcloud_set_config_httpd_context'],
    require  => File["${b2drop::documentroot}"]
  }
  exec{ 'nextcloud_set_config_httpd_context':
    command     => "/sbin/restorecon -Rv ${::b2drop::documentroot}/config",
    refreshonly => true,
    require     => File["${::b2drop::documentroot}"]
  }
  selinux::fcontext{ 'nextcloud_apps_content_httpd_context':
    context  => 'httpd_sys_rw_content_t',
    pathname => "${::b2drop::documentroot}/apps(/.*)?",
    notify   => Exec['nextcloud_set_apps_content_httpd_context'],
    require  => File["${::b2drop::documentroot}"]
  }
  exec{ 'nextcloud_set_apps_content_httpd_context':
    command     => "/sbin/restorecon -Rv ${::b2drop::documentroot}/apps",
    refreshonly => true,
    require     => File["${::b2drop::documentroot}"]
  }

  # configure tmp selinux permissions
  if $::b2drop::manage_tmp {
    selinux::fcontext{ 'custom_tmp_context':
      context  => 'tmp_t',
      pathname => $::b2drop::manage_tmp,
      notify   => Exec['set_custom_tmp_context'],
    }
    exec{ 'set_custom_tmp_context':
      command     => "/sbin/restorecon -Rv ${::b2drop::manage_tmp}",
      refreshonly => true,
      require     => File[$::b2drop::manage_tmp]
    }
  }
}
