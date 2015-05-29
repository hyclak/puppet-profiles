class profiles::base::fw_pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules based on a standard RHEL/CentOS Install
  firewall {
    '000 accept related/established':
      proto   => 'all',
      ctstate => ['RELATED', 'ESTABLISHED'],
      action  => 'accept',
  } ->
  firewall {
    '001 accept all icmp':
      proto  => 'icmp',
      action => 'accept',
  } ->
  firewall {
    '002 accept loopback traffic':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
  } ->
  firewall {
    '003 accept SSH traffic':
      proto   => 'tcp',
      port    => 22,
      ctstate => ['NEW'],
      action  => 'accept',
  } ->
  firewall {
    '004 accept SNMP traffic':
      proto   => 'udp',
      port    => 161,
      ctstate => ['NEW'],
      action  => 'accept',
  }
}
