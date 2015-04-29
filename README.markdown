<<<<<<< HEAD
# sssd

####Table of Contents
1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Quick Start](#quick-start)
4. [Usage - Configuration options and additional functionality](#usage)
   * [Different attribute schema](#different-attribute-schema)
   * [Automatically create home directories](#automatically-create-home-directories)
   * [Authenticate against multiple domains](#authenticate-against-multiple-domains)
5. [Limitations](#limitations)

## Overview
The SSSD module makes it easy to authenticate against Active Directory with sssd.

## Module Description
The SSSD module manages the sssd service on distributions based on RedHat
Enterprise Linux 5 or 6. It is designed to work with Active Directory, but
can easily be customized to work with other LDAP servers. It also helps
automate home directory creation.

## Quick Start
I just want to login with my network username. What's the minimum I need?

    class { 'sssd':
      domains              => [ 'mydomain.local' ],
      make_home_dir        => true,
    }
    sssd::domain { 'mydomain.local':
      ldap_uri             => 'ldap://mydomain.local',
      ldap_search_base     => 'DC=mydomain,DC=local',
      krb5_realm           => 'MYDOMAIN.LOCAL',
      ldap_default_bind_dn => 'CN=SssdService,DC=mydomain,DC=local',
      ldap_default_authtok => 'My ultra-secret password',
      simple_allow_groups  => ['SssdAdmins'],
    }

Note that you must have certificates configured appropriate on your system so
that a secure TLS connection can be established with your LDAP server. On
RedHat-based systems, you need to install certificates of your trusted
certificate authority into `/etc/openldap/certs` and then hash the certs by
running `cacertdir_rehash /etc/openldap/certs`.

## Usage

### Different attribute schema
Most LDAP servers use standard attribute names defined in rfc2307. This
includes Windows Server since 2003 R2. If your directory uses a non-standard
schema for posix accounts, you will need to define a custom attribute mapping.

    sssd::domain { 'mydomain.local':
      ...
      ldap_user_object_class   => 'user',
      ldap_user_name           => 'sAMAccountName',
      ldap_user_principal      => 'userPrincipalName',
      ldap_user_gecos          => 'MSSFU2x-gecos',
      ldap_user_shell          => 'MSSFU2x-loginShell',
      ldap_user_uid_number     => 'MSSFU2x-uidNumber',
      ldap_user_gid_number     => 'MSSFU2x-gidNumber',
      ldap_user_home_directory => 'msSFUHomeDirectory',
      ldap_group_gid_number    => 'MSSFU2x-gidNumber',
    }

### Authenticate against multiple domains
SSSD makes it easy to authenticate against multiple domains. You need to
create a second (or third) `sssd::domain` resource and fill in the
appropriate parameters as shown above.

You also need to add the domain, with the same name, to the array of domains
passed to the sssd class. This defines the lookup order.

    class { 'sssd':
      domains  => [ 'domain_one.local', 'domain_two.local' ],
    }
    sssd::domain { 'domain_one.local':
      ldap_uri => 'ldap://domain_one.local',
      ...
    }
    sssd::domain { 'domain_two.local':
      ldap_uri => 'ldap://domain_two.local',
      ...
    }

### Use Hiera for configuration data
The SSSD module is designed to work with the automatic parameter lookup feature
introduced with Hiera in Puppet 3. If you are using Hiera, you can shorten your
Puppet manifest down to one line:

    include sssd

Then add configuration data into your Hiera data files. If you are using a YAML
backend, your configuration file might look like this.

    sssd::domains:
    - 'mydomain.local'
    sssd::backends:
      'mydomain.local':
        ldap_uri: 'ldap://mydomain.local'
        ldap_search_base: 'DC=mydomain,DC=local'
        krb5_realm: 'MYDOMAIN.LOCAL'
        ldap_default_bind_dn: 'CN=SssdService,DC=mydomain,DC=local'
        ldap_default_authtok: 'My ultra-secret password'
        simple_allow_groups: ['SssdAdmins']

## Limitations
This module has been built on and tested against these Puppet versions:

 * Puppet 3.2.4
 * Puppet 3.2.3
 * Puppet 2.6.18

This module has been tested on the following distributions:

 * Scientific Linux 6.4
 * Scientific Linx 6.3
 * CentOS release 5.6

If you need an SSSD module for Debian, there's one by [Unyonsys]
(https://github.com/Unyonsys/puppet-module-sssd).
=======
# sssd Puppet Module

[![Build Status](https://travis-ci.org/walkamongus/sssd.svg)](https://travis-ci.org/walkamongus/sssd)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sssd](#setup)
    * [What sssd affects](#what-sssd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sssd](#beginning-with-sssd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

This module installs (if necessary) and configures the System Security Services Daemon. 

##Module Description

The System Security Services Daemon bridges the gap between local authentication requests 
and remote authentication providers.  This module installs the required sssd packages and 
builds the sssd.conf configuration file. It will also enable the sssd service and ensure 
it is running. 

Auto-creation of user home directories on first login via the PAM mkhomedir.so module may 
be enabled or disabled (defaults to disabled).

For SSH and Sudo integration with SSSD, this module works well with [saz/ssh](https://forge.puppetlabs.com/saz/ssh) and [trlinkin/nsswitch](https://forge.puppetlabs.com/trlinkin/nsswitch).

##Setup

###What sssd affects

* Packages
    * sssd
    * libsss_idmap
    * authconfig
    * libsss_sudo (legacy)
    * libsss_autofs (legacy)
* Files
    * sssd.conf
* Services
    * sssd daemon
* Execs
    * the authconfig command is run to enable or disable the PAM mkhomedir.so functionality

###Beginning with sssd

Install SSSD with a bare default config file:

     class {'::sssd': }

##Usage

Install SSSD with custom configuration:

    class {'::sssd':
      config => {
        'sssd' => {
          'key'     => 'value',
          'domains' => ['MY_DOMAIN', 'LDAP',],
        }
        'domain/MY_DOMAIN' => {
          'key' => 'value',
        }
        'pam' => {
          'key' => 'value',
        }
      }
    }


##Reference

###Parameters

* `mkhomedir`: Defaults to 'disabled'.  Set to 'enabled' to enable auto-creation of home directories on user login
* `use_legacy_packages`: Boolean. Defaults to false.  Set to true to install the legacy 'libsss_sudo
                         and 'libsss_autofs' packages. These packages were absorbed into the
                         'sssd-common' package.
* `config`: A hash of configuration options stuctured like the sssd.conf file. Array values will be joined into comma-separated lists. 
* `manage_idmap`: Boolean. Defaults to true. Set to false to disable management of the idmap package
* `manage_authconfig`: Boolean. Defaults to true. Set to false to disable management of the authconfig package

For example:

    class {'::sssd':
      config => {
        'sssd' => {
          'key1' => 'value1',
          'keyX' => [ 'valueY', 'valueZ' ],
        },
        'domain/LDAP' => {
          'key2' => 'value2',
        },
      }

or in hiera:

    sssd::config:
      'sssd':
        key1: value1
        keyX:
          - valueY
          - valueZ
      'domain/LDAP':
        key2: value2

Will be represented in sssd.conf like this:

    [sssd]
    key1 = value1
    keyX = valueY, valueZ

    [domain/LDAP]
    key2 = value2

###Classes

* sssd::params
* sssd::init
* sssd::install
* sssd::config
* sssd::service

##Limitations

Developed using:
* Puppet 3.6.2
* CentOS 6.5
>>>>>>> sssdPAM
