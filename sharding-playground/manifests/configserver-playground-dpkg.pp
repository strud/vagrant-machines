# -*- mode: ruby -*-

package { 'vim':
	ensure => present,
}

group { 'puppet':
	ensure => 'present',
}

package { 'libnss-mdns':
	ensure  => present,
}

file { '/home/vagrant/mongo_configdb':
	ensure  => directory,
}

exec { 'mongodb-10gen':
	command => 'dpkg -i /vagrant/mongodb-10gen_2.2.3_amd64.deb',
  path    => '/usr/local/bin/:/bin/:/usr/bin/:/sbin/:/usr/sbin/',
  creates => '/etc/init.d/mongodb',
}

file { '/etc/mongodb.conf':
  ensure  => present,
  source  => '/vagrant/manifests/mongodb.conf',
  require => Exec['mongodb-10gen'],
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
