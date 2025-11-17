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




CEPH_RELEASE=19.2.3
curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm \
  && chmod +x cephadm \
  && sudo mv cephadm /usr/local/bin
sudo cephadm bootstrap --mon-ip 192.168.56.141 --ssh-public-key ~/.ssh/id_ed25519.pub --ssh-private-key ~/.ssh/id_ed25519 --ssh-user mpatron
sudo /usr/local/bin/cephadm bootstrap --mon-ip 192.168.56.141 --ssh-public-key ~/.ssh/id_ed25519.pub --ssh-private-key ~/.ssh/id_ed25519 --ssh-user mpatron

