# -*- mode: ruby -*-

exec { "apt-get update":
  command => "/usr/bin/apt-get update",
  path    => '/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/',
}

package { 'vim':
	ensure  => present,
  require => Exec['apt-get update'],  
}

group { 'puppet':
	ensure => 'present',
}

package { 'libnss-mdns':
	ensure  => present,  
  require => Exec['apt-get update'],  
}

exec { 'mongodb-10gen':
	command => 'dpkg -i /vagrant/mongodb-10gen_2.4.6_amd64.deb',
  path    => '/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/',
  creates => '/etc/init.d/mongodb',
}

file { '/etc/mongodb.conf':
	ensure  => present,
	source  => '/vagrant/manifests/mongodb.conf',
	require => Exec['mongodb-10gen'],
}

service{ 'mongodb':
  ensure => running,
  subscribe => File['/etc/mongodb.conf'],
}
