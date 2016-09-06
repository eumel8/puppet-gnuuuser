# == Class: gnuuuser
#
# Maintaining gnuuu client environments
#
# === Parameters
#
# === Variables
#
# [*site*]
# UUCP Site ID
#
# [*password*]
# UUCP Site Passwort
#
# [repoversion*]
# Repoversion (OpenSUSE_13.1, OpenSUSE_13.2)
#
# === Authors
#
# Frank Kloeker <f.kloeker@t-online.de>
#
#

#                             file {'/etc/nagios':
#                                 ensure  => directory,
#                                     force   => true,
#
#
class gnuuuser(
  $repoversion = 'OpenSUSE_13.2',
  $site        = undef,
  $password    = undef
  ) {


  if ($::operatingsystemrelease == '13.1') {
    file {'/etc/zypp/repos.d/Frank_13.1.repo':
      ensure  => file,
      source  => 'puppet:///modules/gnuuuser/Frank_13.1.repo'
    }
  } 

  if ($::operatingsystemrelease == '13.2') {
    file {'/etc/zypp/repos.d/Frank_13.2.repo':
      ensure  => file,
      source  => 'puppet:///modules/gnuuuser/Frank_13.2.repo',
    }
  } 

  package {
    [ "vim","syslog-ng","openssh","inn","uucp","postfix","bsmtp","alpine","mailx","less","strace","perl-MIME-tools","wget","bind-utils","telnet","traceroute" ]:
    ensure   => installed,
  }

  exec { 'fetch_active_file':
    command => 'wget -o /var/lib/news/active http://www.gnuu.de/config/active',
    user    => 'news',
    creates => '/var/lib/news/active',
    require => Package['inn'],
  }

  exec { 'fetch_newsgroups_file':
    command => 'wget -o /var/lib/news/newsgroups http://www.gnuu.de/config/newsgroups',
    user    => 'news',
    creates => '/var/lib/news/newsgroups',
    require => Package['inn'],
  }

  exec { 'generate_history':
    command => 'makedbz -i -f /var/lib/news/history',
    user    => 'news',
    creates => '/var/lib/news/history',
  }

# uucp conf
  file { '/etc/uucp/call':
    ensure    => file,
    content   => template('gnuuuser/call.erb'),
    require   => Package['uucp'],
  }

  file { '/etc/uucp/config':
    ensure    => file,
    content   => template('gnuuuser/config.erb'),
    require   => Package['uucp'],
  }

  file { '/etc/uucp/port':
    ensure    => file,
    content   => template('gnuuuser/port.erb'),
    require   => Package['uucp'],
  }

  file { '/etc/uucp/sys':
    ensure    => file,
    content   => template('gnuuuser/sys.erb'),
    require   => Package['uucp'],
  }

# news stuff
  service {'inn':
    ensure   => running,
    enable   => true,
    require  => Package['inn'],
  }

  file {'/etc/news/inn.conf':
    ensure  => file,
    content => template('gnuuuser/inn.conf.erb'),
    require => Package['inn'],
    notify  => Service['inn'],
  }

# mail stuff
  service {'postfix':
    ensure   => running,
    enable   => true,
    require  => Package['postfix'],
  }

  file {'/etc/postfix/main.cf':
    ensure  => file,
    content => template('gnuuuser/main.cf.erb'),
    require => Package['postfix'],
    notify  => Service['postfix'],
  }

  file {'/etc/postfix/master.cf':
    ensure  => file,
    content => template('gnuuuser/master.cf.erb'),
    require => Package['postfix'],
    notify  => Service['postfix'],
  }

  file {'/etc/postfix/tranport':
    ensure  => file,
    content => template('gnuuuser/transport.erb'),
    require => Package['postfix'],
    notify  => Exec['postmap_transport'],
  }

  exec {'postmap_transport':
    command     => '/usr/sbin/postmap /etc/postfix/transport',
    user        => 'root',
    refreshonly => true,
    notify      => Service['postfix'],
  }

  file {'/etc/postfix/virtual':
    ensure  => file,
    content => template('gnuuuser/virtual.erb'),
    require => Package['postfix'],
    notify  => Exec['postmap_virtual'],
  }

  exec {'postmap_virtual':
    command     => '/usr/sbin/postmap /etc/postfix/virtual',
    user        => 'root',
    refreshonly => true,
    notify      => Service['postfix'],
  }
}
