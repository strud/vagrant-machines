# -*- mode: ruby -*-

file { '/etc/apt/sources.list.d/10gen.list':
	ensure  => 'present',
	source  => '/vagrant/manifests/10gen.list',
}

exec { "apt-get update":
  command => "/usr/bin/apt-get update",
  path    => '/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/',
  require => [File['/etc/apt/sources.list.d/10gen.list'], Exec['add-10genkey']],
}

exec { 'add-10genkey':
  command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 && /usr/bin/apt-get update && touch /home/vagrant/updated',
  path    => '/usr/local/bin/:/bin/:/usr/bin/',
  creates => '/home/vagrant/updated',
	require => File['/etc/apt/sources.list.d/10gen.list'],
}

package { 'mongodb-10gen':
	ensure  => present,
	require => Exec['add-10genkey'],
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

file { '/etc/mongodb.conf':
	ensure  => present,
	source  => '/vagrant/manifests/mongodb.conf',
	require => Exec['mongodb-10gen'],
}

file { '/home/vagrant/mongo_configdb':
	ensure  => directory,
}

exec { 'start-cfg':
	command => '/usr/bin/mongod --configsvr --dbpath /home/vagrant/mongo_configdb/ --port 27018 > /tmp/mongocfg.log &',
  path    => '/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/',
  onlyif  => 'test `ps -efa | grep mongod --configsrv | wc -l` -lt 1',
	require => [ File['/home/vagrant/mongo_configdb'], Exec['mongodb-10gen'] ],
}

exec { 'start-mongos':
  command => '/bin/sleep 60 && /usr/bin/mongos --configdb configsrv.local:27018 --port 27019 > /tmp/mongos.log &',
  path    => '/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/',
  onlyif  => 'test `ps -efa | grep mongos | wc -l` -lt 1',
  require => Exec['start-cfg', 'mongodb-10gen'],
}
