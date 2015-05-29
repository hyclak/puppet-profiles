class profiles::base::fw_post {
  firewall {
    '999 drop all':
      proto  => 'all',
      action => 'reject',
      reject => 'icmp-host-prohibited',
      before => undef;
    '999 drop all forwarded':
      proto  => 'all',
      chain  => 'FORWARD',
      action => 'reject',
      reject => 'icmp-host-prohibited',
      before => undef,
  }
}

