# MUGBerlin Vagrant definitions

## Purpose

[Vagrant](http://vagrantup.com/) is a nice way to experiment with technologies without polluting your own machine with software.
This is why we use it for experiments in our MongoDB User Group sessions. This repository contains several vagrant definitions for different experiments.

## Preconditions

Please follow the install instructions at http://vagrantup.com/. Use the latest version from vagrant and install the latest version of VirtualBox (the version from the projects homepages are recommended). After the installation, verify that virtualization options are enabled in your bios, if you are using a 'normal' pc. We did not encounter any virtualization problems on macs. 

## The machines

### simple-mongo

This is a single node machine, that just starts up a mongo instance and forwards the relevant ports to the host.
It uses a standard Ubuntu base-box and installs mongo via puppet. 

Usage:
``` 
cd simple-mongo
vagrant up
```

You can now:

- connect via mongo client to localhost:27017 (which is the default)
- use vagrant ssh to connect to the virtual machine and then use the mongo client there
- look at the mongo web-interface by connecting to http://localhost:28017

To shut down the vagrant image use:

```
vagrant halt
```
or

```
vagrant destroy
```
### sharding-playground

This sets up 4 servers with MongoDB connected via a host-only network.

Startup:
```
cd sharding-playground
vagrant up
```

The startup can take a while - it took 4 minutes per instance with my internet connection.

The IP addresses of the 3 shard servers are

- shard01.local
- shard02.local
- shard03.local

The IP adress of the configserver and mongos instance is

- configsrv.local

Each server has the same setup. If you want to connect to a certain server via ssh use (e.g. shard01):

```
vagrant ssh shard01
```

If you want to connect to the MongoDB instances from your host use:

```
mongo --host configsrv.local --port 27019
```

There is nothing set up for the MongoDB servers. Setting up sharding etc. is aimed to be a group task at our user group meeting.

#### Connect to vgrant instance and to mongos

```
vagrant ssh configsrv
mongo --host configsrv.local --port 27019
```

#### Add the shards 

```
sh.addShard( "shard01.local:27017" )
sh.addShard( "shard02.local:27017" )
sh.addShard( "shard03.local:27017" )
```

#### Set chunk size to something demo usable (optional)

```
use config
db.settings.save( { _id:"chunksize", value: 1 } )
```

#### Enable Sharding for wikipedia

```
sh.enableSharding("wikipedia")
```

#### Enable sharding on the collection

```
sh.shardCollection("wikipedia.articles", {_id: 1})
```
or
```
sh.shardCollection("wikipedia.articles", {url: 1})
```
or
```
sh.shardCollection("wikipedia.articles", {title: 1})
```
or
```
sh.shardCollection("wikipedia.articles", {sKey: 1})
```
or (2.4 only)
```
sh.shardCollection("wikipedia.articles", {title: "hashed"})
```
#### Check Shards

To see how the documents are distributed through our little demo cluster, you can run the command below while importing documents:

```
use wikipedia
db.articles.stats()
```

Note: the balancer does not run all the time - it can take a while until the chunks are moved around.

#### Problems

- IP already used within your network
  - open the vagrant fiel and change the ip of all nodes: xxx.vm.network :hostonly, "10.0.0.24" 
- low bandwidth or apt-get problems
  - change the puppet recipies in the vagrant file to puppet.manifest_file  = "sharding-playground-dpkg.pp" or puppet.manifest_file  = "configserver-playground-dpkg.pp"
  - you can download the deb file here http://downloads-distro.mongodb.org/repo/ubuntu-upstart/dists/dist/10gen/binary-amd64/ 

#### Links

Useful link to the MongoDB documentation: http://docs.mongodb.org/manual/administration/sharding/
Details to Hashed Sharding Keys: http://docs.mongodb.org/manual/tutorial/shard-collection-with-a-hashed-shard-key/