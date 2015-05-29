# = Class: profiles::dns_server
#
# This class configures a dns_server 
# *NOTE* Firewall Rules Only 
#
# == Parameters:
#
# == Requires:
#
# puppetlabs-firewall
#
# == Sample Usage:
#
# include profiles::dns_server
#
class profiles::dns_server {
  # Collect information from hiera
  # Expecting at minimum the following
  # ---
  #
  include profiles::base

  firewall {
    '410 Allow DNS Services (udp)':
      ensure => 'present',
      action => 'accept',
      proto  => 'udp',
      dport  => '53',
  }

  firewall {
    '410 Allow DNS Services (tcp)':
      ensure => 'present',
      action => 'accept',
      proto  => 'tcp',
      dport  => '53',
  }
}
