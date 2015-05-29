# = Class: profiles::puppet_server
#
# This class configures a puppet_server with data from hiera
#
# == Parameters:
#
# == Requires:
#
# puppetlabs-firewall
# puppetlabs-puppetdb
# puppetlabs-stdlib
# stephenrjohnson-puppet
# zack-r10k
#
# == Sample Usage:
#
# include profiles::puppet_server
#
class profiles::puppet_server {
  # Collect information from hiera
  # Expecting at minimum the following
  # ---
  $r10k_remote = hiera('r10k::remote')

  include profiles::base
  include stdlib
  include firewall

  # Validate our data
  

  class { 'r10k':
    remote => $r10k_remote,
  }

  class { 'puppet::master':
    storeconfigs    => true,
    environments    => 'directory',
    environmentpath => '/etc/puppet/environments',
    hiera_config    => '$environmentpath/$environment/hiera.yaml',
  }

  class { '::puppetdb':
    ssl_listen_address => '0.0.0.0'
  }

  ini_setting { 'basemodulepath':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'main',
    setting => 'basemodulepath',
    value   => '/etc/puppet/modules',
  }

  firewall {
    '200 Puppet Server':
      ensure => present,
      action => 'accept',
      proto  => 'tcp',
      dport  => '8140',
  }

  firewall {
    '201 PuppetDB':
      ensure => present,
      action => 'accept',
      proto  => 'tcp',
      dport  => '8081',
  }
}
