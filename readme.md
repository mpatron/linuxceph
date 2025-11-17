# readme (on working 🚧 🏗️ ...)

- [https://docs.redhat.com/en/documentation/red_hat_ceph_storage/4/html/installation_guide/red-hat-ceph-storage-considerations-and-recommendations#tuning-considerations-for-the-linux-kernel-when-running-ceph_install](https://docs.redhat.com/en/documentation/red_hat_ceph_storage/4/html/installation_guide/red-hat-ceph-storage-considerations-and-recommendations#tuning-considerations-for-the-linux-kernel-when-running-ceph_install)

![Cepth architecture](images/cepth_basic_cluster.svg "Cepth architecture")

- [https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-almalinux/](https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-almalinux/)
- [https://hackmd.io/@yujungcheng/Hyu623GKi](https://hackmd.io/@yujungcheng/Hyu623GKi)

[vagrant.md](docs/vagrant.md)

~~~bash
[mpatron@node0 ~]$ python3 -m venv ~/venv
[mpatron@node0 ~]$ source ~/venv/bin/activate
(venv) [mpatron@node0 ~]$ python3 -m pip install --upgrade pip
(venv) [mpatron@node0 ~]$ python3 -m pip install ansible
(venv) [mpatron@node0 ~]$ ansible --version
ansible [core 2.15.12]
  config file = None
  configured module search path = ['/home/mpatron/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/mpatron/venv/lib64/python3.9/site-packages/ansible
  ansible collection location = /home/mpatron/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/mpatron/venv/bin/ansible
  python version = 3.9.18 (main, Jul  3 2024, 00:00:00) [GCC 11.4.1 20231218 (Red Hat 11.4.1-3)] (/home/mpatron/venv/bin/python3)
  jinja version = 3.1.4
  libyaml = True
(venv) [mpatron@node0 ~]$ deactivate
[mpatron@node0 ~]$
~~~

Dépendances :
Alors en fait rien sur galaxy, mais pour pip, il y en a une sur importante, c'est passlib pour les mots de passe. Ne pas oublier de faire "pip install -r requirements.txt".

~~~bash
source ~/venv/bin/activate
# ansible-galaxy collection install -r requirements.yml --ignore-certs
# ansible-galaxy role install -r requirements.yml  --ignore-certs
# En une commande :
# ansible-galaxy install --force --ignore-certs --role-file requirements.yml
ansible-galaxy install --role-file requirements.yml
pip install -r requirements.txt
vagrant up --provision --provider=libvirt
vagrant ssh node1
~~~

## Ceph install

~~~bash
ansible-playbook --inventory inventories/ceph --extra-vars "vm_count=6" --extra-vars "vm_domain=jobjects.net" --extra-vars "vm_domain_ip_pattern=192.168.56.14" provision-playbook.yml
# --start-at-task="Install the latest version of podman"

git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible/
git tag
git checkout stable-9.0
~~~

Générer le fichier de configuration avec toutes les valeurs par default :

~~~bash
ansible-config init --disabled -t all > ansible-all-defaults.cfg
~~~



https://www.youtube.com/watch?v=3z6uGRl7AKU

CEPH_RELEASE=19.2.3
curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm \
  && chmod +x cephadm \
  && sudo mv cephadm /usr/local/bin \
  && sudo chown root:root /usr/local/bin/cephadm

sudo cephadm bootstrap --mon-ip 192.168.56.141 --ssh-public-key ~/.ssh/id_ed25519.pub --ssh-private-key ~/.ssh/id_ed25519 --ssh-user mpatron
sudo /usr/local/bin/cephadm bootstrap --mon-ip 192.168.56.141 --ssh-public-key ~/.ssh/id_ed25519.pub --ssh-private-key ~/.ssh/id_ed25519 --ssh-user mpatron --allow-fqdn-hostname

	     URL: https://node1.jobjects.net:8443/
	    User: admin
	Password: 7163hlg8xe
  G3mBugT3IuXuUWkhktPU

# Dans le shell ceph faire :
for i in {2..6}; do
  sudo /usr/local/bin/cephadm shell -- ceph orch host add node$i.jobjects.net 192.168.56.14$i
done
sudo /usr/local/bin/cephadm shell -- ceph orch host ls
sudo /usr/local/bin/cephadm shell -- ceph orch device ls

for i in {1..6}; do
  sudo /usr/local/bin/cephadm shell -- ceph orch daemon add osd node$i.jobjects.net:/dev/vdb
  sudo /usr/local/bin/cephadm shell -- ceph orch daemon add osd node$i.jobjects.net:/dev/vdc
done

sudo /usr/local/bin/cephadm shell -- ceph mgr module enable rgw
sudo /usr/local/bin/cephadm shell -- ceph orch apply rgw myrgw --placement="2 node2.jobjects.net node3.jobjects.net"
sudo /usr/local/bin/cephadm shell -- ceph rgw realm bootstrap monrealm grpjobjects jobjects
sudo /usr/local/bin/cephadm shell -- ceph rgw realm tokens
sudo /usr/local/bin/cephadm shell -- radosgw-admin user create --uid="myuser" --display-name="Mon Utilisateur RGW"


sudo /usr/local/bin/cephadm shell
[ceph: root@node1 /]# ceph -s
  cluster:
    id:     6de2f8cc-c39d-11f0-a21d-5254000e71dc
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3
 
  services:
    mon: 2 daemons, quorum node1,node2 (age 110s)
    mgr: node1.wnulmo(active, since 31m), standbys: node2.muufcc
    osd: 0 osds: 0 up, 0 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:     
 
[ceph: root@node1 /]# ceph orch host ls
HOST                ADDR            LABELS  STATUS  
node1.jobjects.net  192.168.56.141  _admin          
node2.jobjects.net  192.168.56.142                  
node3.jobjects.net  192.168.56.143                  
node4.jobjects.net  192.168.56.144                  
node5.jobjects.net  192.168.56.145                  
node6.jobjects.net  192.168.56.146                  
6 hosts in cluster

