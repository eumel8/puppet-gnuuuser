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

  package {'postfix':
    ensure   => present,
  }
  ->
  package {
    [ "vim","procmail","openssh","inn","uucp","bsmtp","alpine","mailx","less","szip","strace","perl-MIME-tools","wget","bind-utils","telnet","traceroute" ]:
    ensure  => installed,
  }

  exec { 'fetch_active_file':
    command => 'wget -O /var/lib/news/active http://www.gnuu.de/config/active',
    path    => '/bin:/usr/bin',
    user    => 'news',
    creates => '/tmp/active',
    require => [Package['inn'], Package['wget']],
  }

  exec { 'fetch_newsgroups_file':
    command => 'wget -O /var/lib/news/newsgroups http://www.gnuu.de/config/newsgroups',
    path    => '/bin:/usr/bin',
    user    => 'news',
    creates => '/tmp/newsgroups',
    require => [Package['inn'], Package['wget']],
  }

  exec { 'generate_history':
    command => '/usr/lib/news/bin/makedbz -i -f /var/lib/news/history',
    user    => 'news',
    creates => '/var/lib/news/history',
    require => Package['inn'],
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

  file {'/etc/news/newsfeeds':
    ensure  => file,
    owner   => 'news',
    group   => 'news',
    source  => 'puppet:///modules/gnuuuser/newsfeeds',
    require => Package['inn'],
    notify  => Service['inn'],
  }

  file {'/etc/news/readers.conf':
    ensure  => file,
    owner   => 'news',
    group   => 'news',
    source  => 'puppet:///modules/gnuuuser/readers.conf',
    require => Package['inn'],
    notify  => Service['inn'],
  }

  file {'/etc/news/send-uucp.cf':
    ensure  => file,
    owner   => 'news',
    group   => 'news',
    source  => 'puppet:///modules/gnuuuser/send-uucp.cf',
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

  file {'/etc/postfix/transport':
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

  file {'/root/.pinerc':
    ensure  => file,
    content => template('gnuuuser/pinerc.erb'),
  }

}
