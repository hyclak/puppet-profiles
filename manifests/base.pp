# = Class: profile::base
#
# This class is the basis for all hosts 
#
# == Parameters:
#
# 
# == Requires:
#
# jbeard-nfs
# puppetlabs-firewall
# 
# == Sample Usage:
#
# include profiles::base
# 
#
class profiles::base {
  # Purge all existing FW rules
  resources {
    'firewall':
      purge => true
  }

  # This sets up defaults for all firewall resources to fit between pre and post
  Firewall {
    before  => Class['profiles::base::fw_post'],
    require => Class['profiles::base::fw_pre'],
  }

  # Include our firewall definitions
  class { ['::profiles::base::fw_pre', '::profiles::base::fw_post']: }
  include ::firewall

  # NFS Client configuration
  #include nfs::client
  # rpcgssd service? Verify ipa-client-automount doesn't do that
  
  # Sudoers
  file {
    '/etc/sudoers.d/infra_admins':
      ensure  => 'present',
      content => "%admins       ALL=(ALL)       ALL\n"
  }
}
