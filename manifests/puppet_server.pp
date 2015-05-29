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
  include puppetdb

  # Validate our data
  

  class { 'r10k':
    remote => $r10k_remote,
  }

  class { '::puppetdb': }

  class { 'puppet::master':
    storeconfigs    => true,
    environments    => 'directory',
    environmentpath => '/etc/puppet/environments',
    hiera_config    => '$environmentpath/$environment/hiera.yaml',
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
}
