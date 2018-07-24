# Documentation structure

[About this project](#about-this-project)  
[About the lab](#about-the-lab)  
&nbsp;&nbsp;&nbsp;&nbsp;[Building blocks](#building-blocks)  
&nbsp;&nbsp;&nbsp;&nbsp;[Diagram](#diagram)  
&nbsp;&nbsp;&nbsp;&nbsp;[IP addresses and credentials](#ip-addresses-and-credentials)  
[About the use cases](#about-the-use-cases)  
&nbsp;&nbsp;&nbsp;&nbsp;[Junos configuration automatic backup on Git](#junos-configuration-automatic-backup-on-git)  
&nbsp;&nbsp;&nbsp;&nbsp;[Automated Junos show commands collection](#automated-junos-show-commands-collection)  
&nbsp;&nbsp;&nbsp;&nbsp;[Automated tickets management](#automated-tickets-management)  
[Lab preparation instructions](#lab-preparation-instructions)  
&nbsp;&nbsp;&nbsp;&nbsp;[Overview](#overview)  
&nbsp;&nbsp;&nbsp;&nbsp;[Docker](#docker)  
&nbsp;&nbsp;&nbsp;&nbsp;[Request Tracker](#request-tracker)  
&nbsp;&nbsp;&nbsp;&nbsp;[Gitlab](#gitlab)  
&nbsp;&nbsp;&nbsp;&nbsp;[SaltStack](#saltstack)  
[Familiarize yourself with this setup](#familiarize-yourself-with-this-setup)  
[Run the various demos](#run-the-various-demos)  
&nbsp;&nbsp;&nbsp;&nbsp;[Junos configuration automatic backup on Git](#junos-configuration-automatic-backup-on-git-1)  
&nbsp;&nbsp;&nbsp;&nbsp;[Automated Junos show commands collection](#automated-junos-show-commands-collection-1)  
&nbsp;&nbsp;&nbsp;&nbsp;[Automated tickets management](#automated-tickets-management-1)  

# About this project

Lab guide for Juniper automation summit  
July 2018 session - day 3 - Hands on Labs around Event Driven automation. 

# About the lab

## Building blocks 
- Junos devices
- Ubuntu VMs
- SaltStack
- Docker
- Gitlab
- RT (Request Tracker)

## Diagram
![Diagram.png](resources/Diagram.png)  

## Versions 

The ubuntu hosts are running 16.04 release.  
The vMX are running 17.4R1-S2.2  
The other componants will be installed using the below instructions.  


## IP addresses and credentials  
| Name | Operating system | Management IP address  | Username | Password|
| ------------- | ------------- | ------------- |------------- | ------------- |
| minion1    | Ubuntu | 100.123.35.1    | jcluser | Juniper!1 |
| master1    | Ubuntu | 100.123.35.0    | jcluser | Juniper!1 |
| vMX-0    | Junos | 100.123.1.0    | jcluser | Juniper!1 |
| vMX-1    | Junos | 100.123.1.1    | jcluser | Juniper!1 |

# About the use cases

##  Junos configuration automatic backup on Git

At each junos commit, SaltStack automatically collects the new junos configuration file and archives it to a git server: 
- When a Junos commit is completed, the Junos device send a syslog message ```UI_COMMIT_COMPLETED```.  
- The junos devices are configured to send this syslog message to SaltStack.  
- Each time SaltStack receives this syslog message, SaltStack automatically collects the new junos configuration file from the
JUNOS device that send this commit syslog message, and SaltStack automatically archives the new junos configuration file to a git server  

![continous_backup.png](resources/continous_backup.png)  

## Automated Junos show commands collection
Junos automation demo using SaltStack and Gitlab:
- Junos devices send syslog messages to SaltStack.
- Based on syslog messages received, SaltStack automatically collects junos "show commands" output from the JUNOS device that sent a syslog message, and SaltStack automatically archives the collected data on a Git server.

![automated_junos_show_commands_collection_with_syslog_saltstack.png](resources/automated_junos_show_commands_collection_with_syslog_saltstack.png)

## Automated tickets management
Junos automation demo using SaltStack and a ticketing system (Request Tracker):  
- Junos devices send syslog messages to SaltStack.  
- Based on syslog messages received from junos devices: 
  - SaltStack automatically creates a new RT (Request Tracker) ticket to track this issue. If there is already an existing ticket to track this issue, SaltStack updates the existing ticket instead of creating a new one. The syslog messages are added to the appropriate tickets.  
  - SaltStack automatically collects "show commands" output from junos devices and attach the devices output to the appropriate tickets. 

![RT.png](resources/RT.png)  

# Lab preparation instructions

## Overview 
- Install Docker on the ubuntu host ```minion1```.
- Install Gitlab on the ubuntu host ```minion1``` (container).
- Install Request Tracker on the ubuntu host ```minion1``` (container).
- Install SaltStack master on the ubuntu host ```master1```.
- Install SaltStack minion on the ubuntu host ```minion1```.
- Install SaltStack Junos proxy on the  ubuntu host ```minion1```.
- Configure the setup for the above use cases. 

## Docker

### Install Docker on the ubuntu host ```minion1```

Check if Docker is already installed on the ubuntu host ```minion1```
```
$ docker --version
```

If it was not already installed, install it:
```
$ sudo apt-get update
```
```
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
```
$ sudo apt-get update
```
```
$ sudo apt-get install docker-ce
```
```
$ sudo docker run hello-world
```
```
$ sudo groupadd docker
```
```
$ sudo usermod -aG docker $USER
```

Exit the ssh session to ```minion1``` and open an new ssh session to ```minion1``` and run these commands to verify you installed Docker properly:  
```
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```
```
$ docker --version
Docker version 18.03.1-ce, build 9ee9f40
```

## Request Tracker

Request Tracker (RT) is an open source issue tracking system.  
There is a Request Tracker Docker image available https://hub.docker.com/r/netsandbox/request-tracker/  

### Pull a Request Tracker Docker image on the ubuntu host ```minion1```  

Check if you already have it locally:   
```
$ docker images
```

if not, pull the image:
```
$ docker pull netsandbox/request-tracker
```
Verify: 
```
$ docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
netsandbox/request-tracker   latest              b3843a7d4744        4 months ago        423MB
```

### Instanciate a Request Tracker container on the ubuntu host ```minion1``` 
```
$ docker run -d --rm --name rt -p 9081:80 netsandbox/request-tracker
```
Verify: 
```
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS                  PORTS                                                 NAMES
0945209bfe14        netsandbox/request-tracker   "/usr/sbin/apache2 -…"   26 hours ago        Up 26 hours             0.0.0.0:9081->80/tcp                                  rt
```

### Verify you can access to RT GUI

Access RT GUI with ```http://100.123.35.1:9081``` in a browser.  
The default ```root``` user password is ```password```

### Install the ```rt``` python library on the ubuntu host ```master1```

There are python libraries that provide an easy programming interface for dealing with RT:  
- [rtapi](https://github.com/Rickerd0613/rtapi) 
- [python-rtkit](https://github.com/z4r/python-rtkit)
- [rt](https://github.com/CZ-NIC/python-rt) 

Install the ```rt``` library on the ubuntu host ```master1```

```
$ sudo -s
```
```
# apt-get install python-pip
```
```
# pip install requests nose six rt
```
Verify
```
# pip list
```

### Verify you can use ```rt``` Python library on the ubuntu host ```master1```
Python interactive session on the ubuntu host ```master1```: 
```
# python
Python 2.7.12 (default, Dec  4 2017, 14:50:18)
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import rt
>>> tracker = rt.Rt('http://100.123.35.1:9081/REST/1.0/', 'root', 'password')
>>> tracker.url
'http://100.123.35.1:9081/REST/1.0/'
>>> tracker.login()
True
>>> tracker.search(Queue='General', Status='new')
[]
>>> tracker.create_ticket(Queue='General', Subject='abc', Text='bla bla bla')
1
>>> tracker.reply(1, text='notes you want to add to the ticket 1')
True
>>> tracker.search(Queue='General')
[{u'Status': u'open', u'Priority': u'3', u'Resolved': u'Not set', u'TimeLeft': u'0', u'Creator': u'root', u'Started': u'Wed Jul 11 09:30:57 2018', u'Starts': u'Not set', u'Created': u'Wed Jul 11 09:30:10 2018', u'Due': u'Not set', u'LastUpdated': u'Wed Jul 11 09:30:57 2018', u'FinalPriority': u'0', u'Queue': u'General', 'Requestors': [u''], u'Owner': u'Nobody', u'Told': u'Not set', u'TimeEstimated': u'0', u'InitialPriority': u'0', u'id': u'ticket/1', u'TimeWorked': u'0', u'Subject': u'abc'}]
>>> for item in  tracker.search(Queue='General'):
...    print item['id']
...
ticket/1
>>> tracker.logout()
True
>>> exit()
```

### Using RT GUI, verify the ticket details you created previously with Python interactive session

## Gitlab

There is a Gitlab docker image available https://hub.docker.com/r/gitlab/gitlab-ce/  

### Pull a Gitlab Docker image on the ubuntu host ```minion1```

Check if you already have it locally: 
```
$ docker images
```

if not, pull the image:
```
$ docker pull gitlab/gitlab-ce
```
Verify: 
```
$ docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
gitlab/gitlab-ce             latest              504ada597edc        6 days ago          1.46GB
```

### Instanciate a Gitlab container on the ubuntu host ```minion1```

```
$ docker run -d --name gitlab -p 3022:22 -p 9080:80 gitlab/gitlab-ce
```
Verify: 
```
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS                  PORTS                                                 NAMES
eca5b63dcf99        gitlab/gitlab-ce             "/assets/wrapper"        26 hours ago        Up 26 hours (healthy)   443/tcp, 0.0.0.0:3022->22/tcp, 0.0.0.0:9080->80/tcp   gitlab
```

Wait for Gitlab container status to be ```healthy```.  
It takes about 2 mns.  
```
$ watch -n 10 'docker ps'
```

### Verify you can access to Gitlab GUI

Access Gitlab GUI with ```http://100.123.35.1:9080``` in a browser. 
Gitlab user is ```root```    
Create a password ```password```  
Sign in with ```root``` and ```password```  

### Create a group 
Name it ```automation_demo``` (Public)

### Create new projects
Create these new projects in the group ```automation_demo``` 
  - ```variables``` (Public, add Readme)
  - ```files_server``` (Public, add Readme)
  - ```configuration_backup``` (Public, add Readme)
  - ```show_commands_collected``` (Public, add Readme)

### Add your public keys to Gitlab for both the host ```master1``` and the host ```minion1```

Both the host ```master1``` and the host ```minion1``` will inteact with the Gitlab server. 
Run these commands on both hosts.

Generate ssh keys
```
$ sudo -s
```
```
# ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
```
```
# ls /root/.ssh/
id_rsa  id_rsa.pub  known_hosts
```
Add the public key to Gitlab.  
Copy the public key:
```
# more /root/.ssh/id_rsa.pub
```
Access Gitlab GUI with ```http://100.123.35.1:9080``` in a browser, and add the public key of both the host ```master1``` and the host ```minion1``` to ```User Settings``` > ```SSH Keys```

### Update your ssh configuration on both the host ```master1``` and the host ```minion1```
Run these commands on both hosts  
```
$ sudo -s
```
```
# touch /root/.ssh/config
```
```
# ls /root/.ssh/
config       id_rsa       id_rsa.pub   known_hosts
```
```
# vi /root/.ssh/config
```
```
# more /root/.ssh/config
Host 100.123.35.1
Port 3022
Host *
Port 22
```

### Configure your Git client for both the host ```master1``` and the host ```minion1```
Run these commands on both hosts.

```
$ sudo -s
# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"
```

### Verify you can use Git and Gitlab from both the host ```master1``` and the host ```minion1```
```
$ sudo -s
# git clone git@100.123.35.1:automation_demo/variables.git
# git clone git@100.123.35.1:automation_demo/files_server.git
# git clone git@100.123.35.1:automation_demo/configuration_backup.git
# git clone git@100.123.35.1:automation_demo/show_commands_collected.git
# ls
# cd variables
# git remote -v
# git branch 
# ls
# vi README.md
# git status
# git diff README.md
# git add README.md
# git status
# git commit -m 'first commit'
# git log --oneline
# git log
# git push origin master
# cd
#
```

## SaltStack 

We will: 
- install SaltStack master on ubuntu host ```master1```.
- install SaltStack minion on ubuntu host ```minion1```.
- install SaltStack Junos proxy on ubuntu host ```minion1```.  
- configure SaltStack for the various demo

### Master

#### Install SaltStack master on the ubuntu host ```master1``` 
Check if SaltStack master is already installed on the ubuntu host ```master1``` 
```
$ sudo -s
```
```
# salt --version
```
```
# salt-master --version
```
if SaltStack master was not already installed on the ubuntu host ```master1```, then install it: 
```
$ sudo -s
```
```
# wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/2018.3.2/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
```
Add ```deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/2018.3.2 xenial main``` in the file ```/etc/apt/sources.list.d/saltstack.list```
```
# touch /etc/apt/sources.list.d/saltstack.list
```
```
# nano /etc/apt/sources.list.d/saltstack.list
```
```
# more /etc/apt/sources.list.d/saltstack.list
deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/2018.3.2 xenial main
```
```
# sudo apt-get update
```
```
# sudo apt-get install salt-master
```
Verify you installed properly SaltStack master on the ubuntu host ```master1```
```
# salt --version
salt 2018.3.2 (Oxygen)
```
```
# salt-master --version
salt-master 2018.3.2 (Oxygen)
```
#### Configure SaltStack master

on the ubuntu host ```master1```, copy this [SaltStack master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master) in the file ```/etc/salt/master```


#### Restart the salt-master service

Use this command to restart the salt-master service
```
# service salt-master restart
```

#### Verify the salt-master status

To see the Salt processes: 
```
# ps -ef | grep salt
```
To check the status, you can run these commands: 
```
# systemctl status salt-master.service
```
```
# service salt-master status
```

#### SaltStack master log

```
# more /var/log/salt/master 
```
```
# tail -f /var/log/salt/master
```

### Minion

#### Install SaltStack minion on ubuntu host ```minion1``` 
Check if SaltStack minion is already installed on the ubuntu host ```minion1```  
```
# salt-minion --version
```
if SaltStack minion was not already installed on the ubuntu host ```minion1```, then install it: 
```
$ sudo -s
```
```
# wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/2018.3.2/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
```
Add ```deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/2018.3.2 xenial main``` in the file ```/etc/apt/sources.list.d/saltstack.list```
```
# touch /etc/apt/sources.list.d/saltstack.list
```
```
# nano /etc/apt/sources.list.d/saltstack.list
```
```
# more /etc/apt/sources.list.d/saltstack.list
deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/archive/2018.3.2 xenial main
```
```
# sudo apt-get update
```
```
$ sudo apt-get install salt-minion
```
And verify if salt-minion was installed properly installation 
```
# salt-minion --version
salt-minion 2018.3.2 (Oxygen)
```

#### Configure SaltStack minion 

On the minion, copy this [minion configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/minion) in the file ```/etc/salt/minion```

#### Restart the salt-minion service

Use this command to restart the salt-minion service
```
# service salt-minion restart
```

#### Verify the salt-minion status
On the minion:

To see the Salt processes: 
```
# ps -ef | grep salt
```
To check the status: 
```
# systemctl status salt-minion.service
```
```
# service salt-minion status
```

#### Verify the keys on the master 

By default, you need to accept the minions/proxies public keys on the master.   

On the master:  

To list all public keys:
```
# salt-key -L
```
To accept a specified public key:
```
# salt-key -a minion1 -y
```
Or, to accept all pending keys:
```
# salt-key -A -y
```
We changed the [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master) to auto accept the keys.  
So the keys are automatically accepted: 
```
# salt-key -L
Accepted Keys:
minion1
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

#### Verify master <-> minion communication 
on the master 
```
# salt minion1 test.ping
```
```
# salt "minion1" cmd.run "pwd"
```
### Pillars

Pillars are variables (for templates, sls files ...).    
They are defined in sls files, with a yaml data structure.  
There is a ```top``` file. ```top.sls``` file map minions to sls (pillars) files.  

#### Pillars configuration

Refer to the [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master) to know the location for pillars.  
Run these commands on the master to copy [these files](https://github.com/ksator/automation_summit_Q3_2018/tree/master/pillars) at the root of the repository ```variables``` 

```
$ sudo -s
# cd
# git clone https://github.com/ksator/automation_summit_Q3_2018.git
# cp automation_summit_Q3_2018/pillars/* variables/
# ls variables/
# cd variables
# git status
# git add .
# git status
# git commit -m "add pillars"
# git push origin master
# cd
```

#### Pillars configuration verification
Run these commands on the master
```
$ sudo -s
```
```
# salt-run pillar.show_pillar
```
```
# salt-run pillar.show_pillar vMX-1
```

### Proxies

#### Install requirements for SaltStack Junos proxy on the host ```minion1``` 

Run these commands on the host ```minion1``` 

```
$ sudo -s
# apt-get install python-pip
# pip list
# apt-get --auto-remove --yes remove python-openssl
# pip install pyOpenSSL junos-eznc jxmlease jsnapy
# pip list
```

Verify you can use junos-eznc on the host ```minion1``` 
```
# python
Python 2.7.12 (default, Dec  4 2017, 14:50:18)
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from jnpr.junos import Device
>>> dev=Device(host='100.123.1.1', user="jcluser", password="Juniper!1")
>>> dev.open()
Device(100.123.1.1)
>>> dev.facts['version']
'17.4R1-S2.2'
>>> dev.close()
>>> exit()
```
#### Configure the SaltStack proxy 

on the host ```minion1```, copy the [proxy configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/proxy) in the file ```/etc/salt/proxy```  

#### Start SaltStack proxies 

You need one salt proxy process per device.
to start the proxy as a daemon for the device ```vMX-1``` and ```vMX-0```, run these commands on the host ```minion1```:
```
# sudo salt-proxy -d --proxyid=vMX-1
# sudo salt-proxy -d --proxyid=vMX-0
```
you can run this command to start it with a debug log level: 
```
# sudo salt-proxy -l debug --proxyid=vMX-1
```
To see the SaltStack processes, run this command: 
```
# ps -ef | grep salt
```

#### Verify the keys on the master  

By default, you need to accept the minions/proxies public keys on the master.   

On the master:  

To list all public keys:
```
# salt-key -L
```
To accept a specified public key:
```
# salt-key -a vMX-1 -y
```
Or, to accept all pending keys:
```
# salt-key -A -y
```
We changed the [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master) to auto accept the keys.  
So the keys are automatically accepted: 
```
# salt-key -L
Accepted Keys:
minion1
vMX-1
vMX-0
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

#### Verify master <-> proxies communication

On the master: 

```
# salt 'vMX*' test.ping
```
```
# salt 'vMX*' junos.cli "show version"
```

### SaltStack files server

Salt runs a file server to deliver files to minions and proxies.  
The [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master) indicates the location for the file servers.  
We are using an external files servers (repository ```files_server```).  
The file server has Junos configuration templates and SaltStack state files.  

#### Junos configuration templates 

Run these commands on the master to copy these [Junos templates](https://github.com/ksator/automation_summit_Q3_2018/tree/master/junos) at the root of the repository ```files_server```.  

```
# cd
# ls
automation_summit_Q3_2018  configuration_backup  files_server  show_commands_collected  variables
```
```
# cp automation_summit_Q3_2018/junos/* files_server/
# cd files_server/
# git add .
# git commit -m "add junos templates"
# git push origin master
# cd
```

#### SaltStack state files

Salt establishes a client-server model to bring infrastructure components in line with a given policy (salt state modules, in salt state sls files. kind of Ansible playbooks).  

run these commands on the master to copy these [states files](https://github.com/ksator/automation_summit_Q3_2018/tree/master/states) at the root of the repository ```files_server```  

```
# cd
# ls
automation_summit_Q3_2018  configuration_backup  files_server  show_commands_collected  variables
```
```
# cp automation_summit_Q3_2018/states/* files_server/
# cd files_server/
# git add *
# git commit -m "add states files"
# git push origin master
# cd
```

### Configure the repositories ```configuration_backup``` and ```show_commands_collected```

Run this command on the master to create a branch for each device in the repositories ```configuration_backup``` and ```show_commands_collected```  
The state file ```create_git_branch.sls``` will be execute by each proxy. 
```
salt 'vMX-*' state.apply create_git_branch
```
Verify the branches with Gitlab GUI.    


### junos syslog engine

Engines are executed in a separate process that is monitored by Salt. If a Salt engine stops, it is restarted automatically.  
Engines can run on both master and minion.  To start an engine, you need to specify engine information in master/minion config file depending on where you want to run the engine. Once the engine configuration is added, start the master and minion normally. The engine should start along with the salt master/minion.   
Junos_syslog engine  listens to syslog messages from Junos devices, extracts event information and generates and pusblishes messages on SaltStack 0MQ bus.  

#### Install the junos syslog engine dependencies
In the master
```
# pip install pyparsing twisted
```

#### junos syslog engine configuration

We added the junos syslog engine configuration in the [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master) so the junos device should send their syslog messages to the master ip address (100.123.35.0 port 516). 

#### Configure syslog on Junos devices 

The state file [syslog.sls](https://github.com/ksator/automation_summit_Q3_2018/blob/master/states/syslog.sls) uses the junos template [syslog.conf](https://github.com/ksator/automation_summit_Q3_2018/blob/master/junos/syslog.conf) to generate and load Junos configuration to Junos devices.  

To execute the state file [syslog.sls](https://github.com/ksator/automation_summit_Q3_2018/blob/master/states/syslog.sls), run this command on the master:  
```
# salt 'vMX-1' pillar.item syslog_host
```
```
# salt 'vMX*' state.apply syslog
```
```
# salt vMX-1 junos.cli "show system commit"
```
```
# salt vMX-1 junos.cli "show configuration | compare rollback 1"
```
```
# salt vMX-1 junos.cli "show configuration system syslog host 100.123.35.0"
```

#### Verify the salt master receives syslog messages from Junos devices

On the master:
```
# tcpdump -i eth0 port 516 -vv
```

### Reactor

#### map some events to reactor sls files

To map some events to reactor sls files, on the master, copy the [reactor configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/reactor.conf) to ```/etc/salt/master.d/reactor.conf```  
On the master: 
```
# cp automation_summit_Q3_2018/reactor.conf /etc/salt/master.d/
```
Restart the salt master service:
```
# service salt-master restart
```
Verify the reactor operationnal state: 
```
# salt-run reactor.list
```
#### add your reactor sls files to the master
create a ```/srv/reactor/``` directory    
```
# mkdir /srv/reactor/
```
and copy [these sls reactor files](https://github.com/ksator/automation_summit_Q3_2018/tree/master/reactors) to the directory ```/srv/reactor/```
```
# cp automation_summit_Q3_2018/reactors/* /srv/reactor/
```

### Runners

The runner directory is indicated in the [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master)  

On the master, create the directory ```/srv/runners/```
```
# mkdir /srv/runners
```
and add the file [request_tracker.py](https://github.com/ksator/automation_summit_Q3_2018/blob/master/runners/request_tracker.py) to the directory ```/srv/runners/```

```
# cd
# ls
automation_summit_Q3_2018  configuration_backup  files_server  show_commands_collected  variables
```
```
# cp automation_summit_Q3_2018/runners/request_tracker.py /srv/runners/
```

Test your runner: 
```
# salt-run request_tracker.create_ticket subject='test subject' text='test text'
```
Verify using The RT GUI. Access RT GUI with ```http://100.123.35.1:9081``` in a browser. The default ```root``` user password is ```password```  
```
# salt-run request_tracker.change_ticket_status_to_resolved ticket_id=2
```


### Event bus
to watch the 0MQ event bus, run this command on the master 
```
# salt-run state.event pretty=True
```

## Familiarize yourself with this setup

### SaltStack execution modules 

Salt can run commands on various machines in parallel with a flexible targeting system (salt execution modules, in salt commands).  

#### Junos execution module

The Junos execution module provide many functions. 

Here's the list: 
```
# salt vMX-1 sys.list_functions junos
vMX-1:
    - junos.cli
    - junos.commit
    - junos.commit_check
    - junos.diff
    - junos.facts
    - junos.facts_refresh
    - junos.file_copy
    - junos.install_config
    - junos.install_os
    - junos.load
    - junos.lock
    - junos.ping
    - junos.rollback
    - junos.rpc
    - junos.set_hostname
    - junos.shutdown
    - junos.unlock
    - junos.zeroize

```
Here's the Junos execution module documentation 
```
# salt 'vMX-1' junos -d
```
Here's the doc for the cli function of the Junos execution module 
```
# salt 'vMX-1' junos.cli -d
```
Junos execution module usage 
```
# salt 'vMX-1' junos.cli "show version"
```
```
# salt 'vMX-1' junos.rpc get-software-information
```
```
# salt 'vMX-1' junos.facts
```

Various output formats 
```
# salt 'vMX-1' junos.rpc get-software-information --output=yaml
```
```
# salt 'vMX-1' junos.cli "show version" --output=json
```

#### Pillar execution module

Get the pillars for a minion/proxy

```
# salt 'vMX-1' pillar.ls
```
```
# salt 'vMX-1' pillar.items
```

#### Grains execution module

Grains are information collected from minions/proxies.  

Available grains can be listed:
```
# salt 'vMX-1' grains.ls
```
Return all grains:
```
# salt 'vMX-1' grains.items
```
Return one or more grains:
```
# salt 'vMX-1' grains.item os_family zmqversion
```
Junos facts gathered during the connection are stored in proxy grains:  
```
# salt 'vMX-1' grains.item junos_facts
```

### SaltStack flexible targeting system

regex
```
# salt '*' test.ping
```
```
# salt 'vMX*' junos.cli "show version"
```
list
```
# salt -L 'vMX-1,vMX-0' junos.cli "show version"
```
grain
```
# salt -G 'junos_facts:model:vMX' junos.cli "show version"
```
group configured in the [master configuration file](https://github.com/ksator/automation_summit_Q3_2018/blob/master/master)
```
# salt -N vmxlab test.ping
```


### SaltStack state module

Salt establishes a client-server model to bring infrastructure components in line with a given policy (salt state modules, in salt state sls files. kind of Ansible playbooks).  

#### SaltStack Junos state module

Here's the list of functions available in the junos state module:  
```
# salt vMX-1 sys.list_state_functions junos
vMX-1:
    - junos.cli
    - junos.commit
    - junos.commit_check
    - junos.diff
    - junos.file_copy
    - junos.install_config
    - junos.install_os
    - junos.load
    - junos.lock
    - junos.rollback
    - junos.rpc
    - junos.set_hostname
    - junos.shutdown
    - junos.unlock
    - junos.zeroize
```

### SaltStack state files

Salt state modules are used in salt state sls files (kind of Ansible playbooks).  

#### SaltStack state files examples  

##### the state file [bgp.sls](https://github.com/ksator/automation_summit_Q3_2018/blob/master/states/bgp.sls)  
This file render the template [bgp.conf](https://github.com/ksator/automation_summit_Q3_2018/blob/master/junos/bgp.conf) using the vMX [variables](https://github.com/ksator/automation_summit_Q3_2018/blob/master/variables/) and load the generated configuration to the vMX. 
```
# salt 'vMX*' state.apply bgp
```
```
# salt vMX-1 junos.cli "show system commit"
```
```
# salt vMX-1 junos.cli "show configuration | compare rollback 1"
```
```
# salt 'vMX*' junos.cli "show bgp neighbor"
```
```
# salt vMX-1 junos.ping 192.168.0.4
```
```
# salt vMX-1 junos.cli 'show route protocol bgp'
```

##### the state file [collect_show_commands_example.sls](https://github.com/ksator/automation_summit_Q3_2018/blob/master/states/collect_show_commands_example.sls)  
This file collects show commands output from a Junos device.  
To execute this file, run this command on the master: 
```
# salt vMX-1 state.apply collect_show_commands_example
```
Run this command on the master to know the name of the host that runs the Junos proxy daemon for the device ```vMX1```:
```
# salt vMX-1 grains.item nodename
```
On that host, run these commands:
```
# ls /tmp/
```
```
# more /tmp/show_chassis_hardware.txt
```
```
# more /tmp/show_version.txt
```

##### the state file [collect_data_locally.sls](https://github.com/ksator/automation_summit_Q3_2018/blob/master/states/collect_data_locally.sls)
This file collects show commands output from Junos devices and save the output locally (on the salt component that runs the salt proxy daemon).    
To execute this file, run this command on the master: 
```
# salt 'vMX*' state.apply collect_data_locally
```
Run this command on the master to know the name of the host that runs the Junos proxy daemon for the device ```vMX1```:
```
# salt 'vMX*' grains.item nodename
```
On that host, run these commands:
```
# ls -l /tmp/vMX-1/
```
```
# ls -l /tmp/vMX-0/
```

##### the state file [collect_show_commands_and_archive_to_git.sls](https://github.com/ksator/automation_summit_Q3_2018/blob/master/states/collect_show_commands_and_archive_to_git.sls)
This file collects show commands output from Junos devices and upload the output to a git server (repository ```show_commands_collected```)    
So the minion that run the proxy will interact with the git server.  
To apply the state file ```collect_show_commands_and_archive_to_git.sls```, run this command on the master: 
```
salt 'vMX-1' state.apply collect_show_commands_and_archive_to_git
```
Verify using the GUI of the repository ```show_commands_collected```  


# Run the various demos 

## Junos configuration automatic backup on Git

Update the reactor file:
```
# more /etc/salt/master.d/reactor.conf
reactor:
    - 'jnpr/syslog/*/UI_COMMIT_COMPLETED':
        - /srv/reactor/backup_configuration.sls
```
Restart the salt master service each time you update the reactor file: 
```
# service salt-master restart
```
List currently configured reactors:
```
# salt-run reactor.list
```
Run this command on the master to see the syslog messages sent by junos devices:
```
tcpdump -i eth0 port 516 -vv
```
Salt provides a runner that displays events in real-time as they are received on the Salt master.
Run this command on the master:
```
salt-run state.event pretty=True
```
Apply a configuration change on a Junos device: 
```
# salt vMX-1 junos.install_config 'salt://banner.set' comment='Committed via SaltStack'
```
Verify on the GUI of the Gitlab repository ```configuration_backup```

## Automated Junos show commands collection

Update the reactor file:
```
# more /etc/salt/master.d/reactor.conf
reactor:
    - 'jnpr/syslog/*/SNMP_TRAP_LINK_*':
        - /srv/reactor/collect_show_commands.sls
```
Restart the salt master service each time you update the reactor file: 
```
# service salt-master restart
```
List currently configured reactors:
```
# salt-run reactor.list
```
Run this command on the master to see the syslog messages sent by junos devices:
```
tcpdump -i eth0 port 516 -vv
```
Salt provides a runner that displays events in real-time as they are received on the Salt master.
Run this command on the master:
```
salt-run state.event pretty=True
```
Apply a configuration change on a Junos device: 
```
# salt vMX-1 junos.install_config 'salt://disable_interface.set' confirm=1

```
Verify on the GUI of the Gitlab repository ```show_commands_collected```



## Automated tickets management

Update the reactor file:
```
root@ubuntu:~# more  /etc/salt/master.d/reactor.conf
reactor:
    - 'jnpr/syslog/*/SNMP_TRAP_LINK_*':
        - /srv/reactor/manage_ticket.sls
```
Restart the salt master service each time you update the reactor file: 
```
# service salt-master restart
```
List currently configured reactors:
```
# salt-run reactor.list
```
Run this command on the master to see the syslog messages sent by junos devices:
```
tcpdump -i eth0 port 516 -vv
```
Salt provides a runner that displays events in real-time as they are received on the Salt master.
Run this command on the master:
```
salt-run state.event pretty=True
```
Apply a configuration change on a Junos device: 
```
# salt vMX-1 junos.install_config 'salt://disable_interface.set' confirm=1

```
Verify the ticket details on the RT GUI 

