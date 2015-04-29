<<<<<<< HEAD
# == Class: sssd::params
# Set up parameters that vary based on platform or distribution.
# 
# UID_MIN is the lowest uid allowed for use by non-system accounts.
# UID_MIN is often defined in /etc/login.defs
# As of RedHat Enterprise Linux 6, UID_MIN is still 500.
# But in Fedora >= 16, UID_MIN has been changed to 1000.
# https://fedoraproject.org/wiki/Features/1000SystemAccounts
# I'm choosing to set 1000 as the default here, to be safe and
# forward-compatible.
#
# === Examples
# class { 'sssd::params': }
#
# === Authors
# Nicholas Waller <code@nicwaller.com>
#
# === Copyright
# Copyright 2013 Nicholas Waller, unless otherwise noted.
=======
# == Class sssd::params
#
# This class is meant to be called from sssd
# It sets variables according to platform
>>>>>>> sssdPAM
#
class sssd::params {
  case $::osfamily {
    'RedHat': {
<<<<<<< HEAD
      $dist_uid_min = 1000
    }
    default: {
      fail('Unsupported distribution')
=======
      $sssd_package_name       = 'sssd'
      $service_name            = 'sssd'
      $config_file             = '/etc/sssd/sssd.conf'
      $config                  = {}
      $default_config          = {
        'sssd'                  => {
          'config_file_version' => '2',
          'services'            => 'nss,pam',
          'domains'             => 'LDAP',
        },
        'nss'                 => {},
        'pam'                 => {},
        'domain/LDAP'         => {
          'id_provider'       => 'ldap',
          'cache_credentials' => true,
        },
      }
      $mkhomedir               = 'disabled'
      $enable_mkhomedir_cmd    = '/usr/sbin/authconfig --enablemkhomedir --update'
      $disable_mkhomedir_cmd   = '/usr/sbin/authconfig --disablemkhomedir --update'
      $pam_mkhomedir_check     = '/bin/grep -E \'^USEMKHOMEDIR=yes$\' /etc/sysconfig/authconfig'
      $manage_idmap            = true
      $idmap_package_name      = 'libsss_idmap'
      $manage_authconfig       = true
      $authconfig_package_name = 'authconfig'
      $use_legacy_packages     = false
      $legacy_package_names    = [
        'libsss_sudo',
        'libsss_autofs',
      ]
    }
    default: {
      fail("${::operatingsystem} not supported")
>>>>>>> sssdPAM
    }
  }
}
