# = Class: profiles::dhcp_server
#
# This class configures a dhcp_server with data from hiera
#
# == Parameters:
#
# == Requires:
#
# puppetlabs-dhcp
# puppetlabs-firewall
# puppetlabs-stdlib
#
# == Sample Usage:
#
# include profiles::dhcp_server
#
class profiles::dhcp_server {
  # Collect information from hiera
  # Expecting at minimum the following
  # ---
  # dhcp::dnsdomain:
  #   - 'domain.name'
  # dhcp::nameservers:
  #   - '8.8.8.8'
  #   - '8.8.4.4'
  # dhcp::ntpservers: (OPTIONAL)
  #   - '8.8.8.8'
  #   - '8.8.4.4'
  # dhcp::interfaces:
  #   - 'eth0' # Note that in RHEL7, this is no longer necessary, but the module requires it
  # dhcp::pools: # Note that this is a hash, not an array!
  #   pool1:
  #     network: '10.0.0.0'
  #     mask: '255.255.255.0'
  #     gateway: '10.0.0.1'
  #     range:
  #       - '10.0.0.100 10.0.0.150'
  #   pool2:
  #     network: '10.10.10.0'
  #     mask: '255.255.255.0'
  #     gateway: '10.10.10.1'
  #     range:
  #       - '10.10.10.50 10.10.10.250'
  # dhcp::hosts: (OPTIONAL)
  #   host1:
  #     mac: '00:11:22:33:44:55'
  #     ip: '10.10.10.99'
  $dhcp_dnsdomain   = hiera('dhcp::dnsdomain')
  $dhcp_nameservers = hiera('dhcp::nameservers')
  $dhcp_ntpservers  = hiera('dhcp::ntpservers', ['0.us.pool.ntp.org', '1.us.pool.ntp.org'])
  $dhcp_interfaces  = hiera('dhcp::interfaces')
  $dhcp_pools       = hiera('dhcp::pools')
  $dhcp_hosts       = hiera('dhcp::hosts', {})

  include profiles::base
  include stdlib

  # Validate our data
  validate_array($dhcp_dnsdomain)
  validate_array($dhcp_nameservers)
  validate_array($dhcp_ntpservers)
  validate_array($dhcp_interfaces)
  validate_hash($dhcp_pools)
  validate_hash($dhcp_hosts)

  class { 'dhcp':
    dnsdomain   => $dhcp_dnsdomain,
    nameservers => $dhcp_nameservers,
    ntpservers  => $dhcp_ntpservers,
    interfaces  => $dhcp_interfaces,
  }

  create_resources('dhcp::pool', $dhcp_pools)

  # Only create hosts if some were found in hiera
  if !empty($dhcp_hosts) {
    create_resources('dhcp::host', $dhcp_hosts)
  }

  firewall {
    '400 Allow DHCP/TFTP Services':
      ensure => 'present',
      action => 'accept',
      proto  => 'udp',
      dport  => [67, 68, 69],
  }
}
