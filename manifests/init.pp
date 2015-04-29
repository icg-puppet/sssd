# == Class: sssd
<<<<<<< HEAD
# Manage SSSD authentication on RHEL-based systems.
#
# === Parameters
# [*domains*]
# Required. Array. For each sssd::domain type you declare, you SHOULD also
# include the domain name here. This defines the domain lookup order.
#
# [*backends*]
# Optional. Hash. The typical way of setting up backends for SSSD is by using
# the sssd::domain defined type. That poses a problem if you want to use
# Hiera for storing your configuration data. This parameter allows you to
# pass a hash that is used to automatically instantiate sssd::domain types.
#
# [*filter_users*]
# Optional. Array. Default is 'root'. Exclude specific users from being
# fetched using sssd. This is particularly useful for system accounts.
#
# [*filter_groups*]
# Optional. Array. Default is 'root'. Exclude specific groups from being
# fetched using sssd. This is particularly useful for system accounts.
#
# [*make_home_dir*]
# (true|false) Optional. Boolean. Default is false. Enable this if you
# want network users to have a home directory created when they login.
#
# === Requires
# - [ripienaar/concat]
# - [puppetlab/stdlib]
#
# === Example
# class { 'sssd':
#   domains => [ 'uni.adr.unbc.ca' ],
# }
#
# === Authors
# Nicholas Waller <code@nicwaller.com>
#
# === Copyright
# Copyright 2013 Nicholas Waller, unless otherwise noted.
#
class sssd (
  $domains,
  $backends        = undef,
  $make_home_dir   = false,
  $filter_users    = [ 'root' ],
  $filter_groups   = [ 'root' ]
) {
  validate_array($domains)
  validate_array($filter_users)
  validate_array($filter_groups)
  validate_bool($make_home_dir)

  if $backends != undef {
    create_resources('sssd::domain', $backends)
  }

  package { 'sssd':
    ensure      => installed,
  }
  
  concat { 'sssd_conf':
    path        => '/etc/sssd/sssd.conf',
    mode        => '0600',
    # SSSD fails to start if file mode is anything other than 0600
    require     => Package['sssd'],
  }
  
  concat::fragment{ 'sssd_conf_header':
    target  => 'sssd_conf',
    content => template('sssd/header_sssd.conf.erb'),
    order   => 10,
  }

  if $make_home_dir {
    class { 'sssd::homedir': }
  }

  exec { 'authconfig-sssd':
    command     => '/usr/sbin/authconfig --enablesssd --enablesssdauth --enablelocauthorize --update',
    refreshonly => true,
    subscribe   => Concat['sssd_conf'],
  }
  
  service { 'sssd':
    ensure      => running,
    enable      => true,
    subscribe   => Exec['authconfig-sssd'],
  }

  service { 'crond':
    subscribe   => Service['sssd'],
  }
=======
#
# Full description of class sssd here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class sssd (

  $sssd_package_name       = $sssd::params::sssd_package_name,
  $sssd_plugin_packages    = $sssd::params::sssd_plugin_packages,
  $service_name            = $sssd::params::service_name,
  $config                  = $sssd::params::config,
  $mkhomedir               = $sssd::params::mkhomedir,
  $enable_mkhomedir_cmd    = $sssd::params::enable_mkhomedir_cmd,
  $disable_mkhomedir_cmd   = $sssd::params::disable_mkhomedir_cmd,
  $pam_mkhomedir_check     = $sssd::params::pam_mkhomedir_check,
  $manage_idmap            = $sssd::params::manage_idmap,
  $idmap_package_name      = $sssd::params::idmap_package_name,
  $use_legacy_packages     = $sssd::params::use_legacy_packages,
  $legacy_package_names    = $sssd::params::legacy_package_names,
  $manage_authconfig       = $sssd::params::manage_authconfig,
  $authconfig_package_name = $sssd::params::authconfig_package_name,

) inherits sssd::params {

  validate_string(
    $sssd_package_name,
    $service_name,
    $enable_mkhomedir_cmd,
    $disable_mkhomedir_cmd,
    $pam_mkhomedir_check,
    $idmap_package_name,
    $authconfig_package_name
  )
  validate_re(
    $mkhomedir,
    [ '^disabled$', '^enabled$' ],
    'The mkhomedir parameter value should be set to "disabled" or "enabled"'
  )
  validate_array($legacy_package_names)
  validate_bool(
    $use_legacy_packages,
    $manage_idmap,
    $manage_authconfig
  )
  validate_hash($config)

  class { 'sssd::install': } ->
  class { 'sssd::config': } ~>
  class { 'sssd::service': } ->
  Class['sssd']
>>>>>>> sssdPAM
}
