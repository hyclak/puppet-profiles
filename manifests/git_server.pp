# = Class: profiles::git_server
#
# This class configures a git_server with data from hiera
#
# == Parameters:
#
# $manage_git_user:: boolean to manage git user/home directory or not
# $git_user:: username for git user
# $git_group:: group name for git group
# $git_uid:: UID for git user
# $git_group:: GID for git group
# $git_homedir:: home directory for git user
#
# == Requires:
#
# puppetlabs-firewall
# puppetlabs-lvm
# puppetlabs-stdlib
# sgzijl-lvmconfig
# theforeman-git
#
# == Sample Usage:
#
# class { 'profiles::git_server': 
#   manage_git_user => true,
# }
#
class profiles::git_server (
  $manage_git_user = false,
  $git_user        = 'git',
  $git_group       = 'git',
  $git_uid         = '450',
  $git_gid         = '450',
  $git_homedir     = '/srv/git',
) {
  # Collect information from hiera
  # Expecting at minimum the following
  # ---
  # vg_layout:
  #   'vg_data':
  #     pvs: '/dev/sdb'
  # lv_layout:
  #   'lv_foo':
  #     vg: 'vg_data'
  #     fs: 'xfs'
  #     mnt_point: '/srv/git'
  #     mnt_opts: 'defaults'
  #     size: '1024M'  # NOTE: Sizes are given in Megabytes
  # git::repo_defaults:
  #   bare: true
  #   user: 'git'
  #   require: "File[%{hiera('git::repo_directory')}]"
  # git::repo_directory: '/srv/git/repos'
  # git::repos:
  #   repo1:
  #     target: '/srv/git/repos/repo1.git'
  #   repo2:
  #     target: '/srv/git/repos/repo2.git'
  $repo_defaults  = hiera('git::repo_defaults')
  $repo_directory = hiera('git::repo_directory')
  $repos          = hiera('git::repos')

  include profiles::base
  include lvmconfig
  include stdlib
  include git

  # Validate our data
  validate_bool($manage_git_user)
  validate_absolute_path($repo_directory)
  validate_absolute_path($git_homedir)
  validate_hash($repo_defaults)
  validate_hash($repos)

  if $manage_git_user {
    group { $git_group:
      gid    => $git_gid,
      system => true,
      before => File[$git_homedir],
    } ->

    user { $git_user:
      uid    => $git_uid,
      gid    => $git_group,
      home   => $git_homedir,
      system => true,
      before => File[$git_homedir],
    }
  }

  file { $git_homedir:
    ensure => directory,
    owner  => 'git',
    group  => 'git',
  }

  file { "${git_homedir}/.ssh":
    ensure  => directory,
    owner   => $git_user,
    group   => $git_group,
    seluser => 'unconfined_u',
    selrole => 'object_r',
    seltype => 'ssh_home_t',
    require => File[$git_homedir],
  } ->

  file { "${git_homedir}/.ssh/authorized_keys":
    owner   => $git_user,
    group   => $git_group,
    seluser => 'unconfined_u',
    selrole => 'object_r',
    seltype => 'ssh_home_t',
  }

  file { $repo_directory:
    owner  => $git_user,
    group  => $git_group,
    ensure => 'directory',
  }

  create_resources(git::repo, $repos, $repo_defaults)
}
