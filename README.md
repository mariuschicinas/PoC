# Table of Content:
* **Test tasks**
* **Requirements**
* **Details for clusters**


# Test tasks
Requirement to task implementation:
Solution must contain a valid Vagrantfile to test solution
All logic must be implemented via Ansible Playbooks/Roles
You can use public Ansible roles, Ansible Galaxy is preferred source
Solution must contain basic README

Redis Cluster
Implement Ansible playbook to deploy Redis cluster in docker containers.
After first playbook run, Redis cluster must be properly initialized. Redis data should be persistent on host.

RabbitMQ cluster
Implement Ansible Playbook to deploy RabbitMQ cluster in docker containers.
After first playbook run, RabbitMQ cluster must be properly initialized. Management interface must be present, admin username and password must be configurable via Ansible variables.

MySQL replication
Implement Ansible Playbook which deploys MySQL master and slave in Docker containers. First playbook run must result in replication process running with now errors. MySQL data directories must be persisted on hosts disk.

----
## Requirements
To run the all services install:

1. Ansible [Ansible install doc](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). Version used: 2.8.5
2. Vagrant [Vagrant install page](https://www.vagrantup.com/downloads.html). Version used : 2.2.6
3. Vagrant plugin: [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
4. Vagrant plugin [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager)
5. VirtualBox for provider [Virtualbox download page](https://www.virtualbox.org/)

----
### Notes:
Because the clusters are POC , such as Redis ports and Mysql port are not open to the host. All containers are in separate VMs, because the meaning of the cluster is not just to repicate data but high availability and redundancy.
The Vagrantfiles are separated for every stack, because the services want resources and will be very heavy for the system requirements to have 8 running VMs.  

For the clusters is used Virtualbox so they can be tested on local environment. All Vagrantfiles are with different configuration to expose different provisioning scenarios. Docker network fo some of them was not used on purpose.  
There are ansible roles from Ansible Galaxy just to show how they can be used. All custom roles contains only the nessessary folders.
The Ansible is written with different tasks and modules to show how they can be used.
For Redis cluster is added desibled role which can be used from DevOps engineers to debug and test easily with the Linux tools.
For RabbitMQ is added additional file called "user.yml". There are defined user and the password for the rabbitmq management page. The idea is to have them separated and with ansible Vault can be secured.  
For Mysql are used different Ansible playbooks to expose how can be with different provisioning scenarios.

----
# Redis cluster
### Usage:
1. Vagrant file creates 3 hosts with names *node1*, *node2* and *node3*. 
2. Ansible playbook:  
Adds *vagrant* user to docker group. Installs *docker* on all hosts. Installs *redis* containers from *redis:5-alpine* with config files. Waits for all redis services to be ready and finally starts redis cluster.
3. Run from folder *redis*:  
`vagrant up`
4. Remove the hosts with   
`vagrant destroy -f`

> Additionally there is a role called **ops-tools**. Contains some useful Linux tools like *htop*, *lsof*, *telnet* and more.   
Also this role adds a great *bashrc*. 
``roles:
    # - role:../roles/ops-tools``
Just uncomment the line in the playbook  

To test redis cluster, run this command from command line:
``vagrant ssh node1 -c "docker exec redis /bin/sh -c 'redis-cli cluster info'"``

----
# Rabbitmq cluster
### Usage:
1. Vagrantfile creates 3 hosts with names *rabbit1*, *rabbit2* and *rabbit3*. Every host will contains one docker container.
2. Ansible playbook:  
This time Ansible playbook installs *docker* from **Ansible galaxy**. Installs rabbitmq from image *rabbitmq:3-management*. Waits for all services to be present and starts the cluster.
3. Run from folder *rabbitmq*:
    `vagrant up`
4. Remove the hosts with `vagrant destroy -f`



> To expose the management port to the browser is added **forwarded_port** in Vagrantfile. 
The user and the password are **Ansible variables** in ``/group_vars/user.yml``. The access is
``http://localhost:15672``

----

# Mysql cluster
### Usage:
1. Vagrant file creates 2 hosts with names *mysqlmaster* and *mysqlslave*. For each host is different Ansible playbook.
2. Ansible playbooks:  
Ansible playbooks installs *docker* from image *mysql:5.7*. Creates folders for *mysql data* and *mysql.cfg*. Mysql data folders are persistent. Finally starts replication between the hosts. It is *master-slave* replication.
3. Run from folder *mysql*:
    `vagrant up`
4. Remove the hosts with `vagrant destroy -f`



> To test the replication:  
List the current databases on mysqlmaster:  
 ``vagrant ssh mysqlmaster -c  "docker exec mysqlmaster mysql -proot -e 'show databases'"``  
Add new database  
``vagrant ssh mysqlmaster -c  "docker exec mysqlmaster mysql -proot -e 'create database test1'"``  
Check the new database on second host:  
``vagrant ssh mysqlslave -c  "docker exec mysqlslave mysql -proot -e 'show databases'"``  
Additionally check the status  
``vagrant ssh mysqlslave -c  "docker exec mysqlslave mysql -proot -e 'show slave status \G'"``
