# = Class: profiles::nfs_server
#
# This class configures a nfs_server with data from hiera
#
# == Parameters:
#
# == Requires:
#
# jbeard-nfs
# puppetlabs-firewall
# puppetlabs-lvm
# sgzijl-lvmconfig
#
# == Sample Usage:
#
# include profiles::nfs_server
#
class profiles::nfs_server {
  # Collect information from hiera
  # Expecting the following (see reference:
  #   https://github.com/sgzijl/lvmconfig/blob/master/example/hiera_lvmconfig.yaml)
  # ---
  # vg_layout:
  #   'vg_data':
  #     pvs: '/dev/sdb'
  #
  # lv_layout:
  #   'lv_foo':
  #     vg: 'vg_data'
  #     fs: 'xfs'
  #     mnt_point: '/srv/nfs/foo'
  #     mnt_opts: 'defaults'
  #     size: '1024M'  # NOTE: Sizes are given in Megabytes
  #
  # nfs::exports:
  #   '/srv/nfs/foo':
  #     clients: ['*']
  #     options: 
  #       - 'rw'
  #       - 'sync'
  #       - 'no_root_squash'
  #       - 'no_wdelay'
  #       - 'sec=sys:krb5:krb5i:krb5p
  # nfs::full_access_hosts: # Optional - allows unrestricted access through firewall
  #   '100 Full Access from 10.0.0.25'
  #     'source': '10.0.0.25'
  #   '100 Full Access from 10.0.0.26'
  #     'source': '10.0.0.26'
  $nfs_exports = hiera('nfs::exports')
  $nfs_full_access_hosts = hiera('nfs::full_access_hosts', {})

  include stdlib
  include profiles::base
  include lvmconfig
  include nfs::server
  
  validate_hash($nfs_exports)
  validate_hash($nfs_full_access_hosts)

  create_resources('nfs::export', $nfs_exports)

  firewall {
    '150 NFS Server ports':
      ensure => 'present',
      action => 'accept',
      proto  => 'tcp',
      dport  => '2049',
  }

  if !empty($nfs_full_access_hosts) {
    $firewall_defaults = {
      ensure => 'present',
      action => 'accept',
    }

    create_resources(firewall, $nfs_full_access_hosts, $firewall_defaults)
  }
  
}

