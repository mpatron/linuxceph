# readme (on working 🚧 🏗️ ...)

![Cepth architecture](images/cepth_basic_cluster.svg "Cepth architecture")

- [https://docs.redhat.com/en/documentation/red_hat_ceph_storage/4/html/installation_guide/red-hat-ceph-storage-considerations-and-recommendations#tuning-considerations-for-the-linux-kernel-when-running-ceph_install](https://docs.redhat.com/en/documentation/red_hat_ceph_storage/4/html/installation_guide/red-hat-ceph-storage-considerations-and-recommendations#tuning-considerations-for-the-linux-kernel-when-running-ceph_install)
- [https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-almalinux/](https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-almalinux/)
- [https://hackmd.io/@yujungcheng/Hyu623GKi](https://hackmd.io/@yujungcheng/Hyu623GKi)
- [https://www.youtube.com/watch?v=3z6uGRl7AKU](https://www.youtube.com/watch?v=3z6uGRl7AKU)

[vagrant.md](docs/vagrant.md)

~~~bash
[vagrant@node0 ~]$ python3 -m venv ~/venv
[vagrant@node0 ~]$ source ~/venv/bin/activate
(venv) [vagrant@node0 ~]$ python3 -m pip install --upgrade pip
(venv) [vagrant@node0 ~]$ python3 -m pip install ansible
(venv) [vagrant@node0 ~]$ ansible --version
ansible [core 2.15.12]
  config file = None
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/vagrant/venv/lib64/python3.9/site-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/vagrant/venv/bin/ansible
  python version = 3.9.18 (main, Jul  3 2024, 00:00:00) [GCC 11.4.1 20231218 (Red Hat 11.4.1-3)] (/home/vagrant/venv/bin/python3)
  jinja version = 3.1.4
  libyaml = True
(venv) [vagrant@node0 ~]$ deactivate
[vagrant@node0 ~]$
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

## Installation de Ceph avec cephadm (fonctionne)

~~~bash
CEPH_RELEASE=19.2.3 curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm \
  && chmod +x cephadm \
  && sudo mv cephadm /usr/local/bin \
  && sudo chown root:root /usr/local/bin/cephadm
sudo /usr/local/bin/cephadm bootstrap --mon-ip 192.168.56.141 --ssh-public-key ~/.ssh/id_ed25519.pub --ssh-private-key ~/.ssh/id_ed25519 --ssh-user vagrant --allow-fqdn-hostname
~~~

~~~txt
URL: https://node1.jobjects.net:8443/
User: admin
Password: 7163hlg8xe
G3mBugT3IuXuUWkhktPU
~~~

Installation en shell directement dans la VM node1

~~~bash
# Dans le shell ceph faire :
for i in {1..6}; do
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
~~~

~~~bash
[vagrant@node1 ~]$ sudo /usr/local/bin/cephadm shell -- ceph --status
Inferring fsid 62501170-c3b6-11f0-86bf-525400285b89
Inferring config /var/lib/ceph/62501170-c3b6-11f0-86bf-525400285b89/mon.node1/config
Using ceph image with id 'aade1b12b8e6' and tag 'v19' created on 2025-07-17 19:53:27 +0000 UTC
quay.io/ceph/ceph@sha256:af0c5903e901e329adabe219dfc8d0c3efc1f05102a753902f33ee16c26b6cee
  cluster:
    id:     62501170-c3b6-11f0-86bf-525400285b89
    health: HEALTH_OK
 
  services:
    mon: 5 daemons, quorum node1,node2,node3,node6,node5 (age 40m)
    mgr: node1.ksnxqh(active, since 22m), standbys: node2.yzpobn
    osd: 12 osds: 12 up (since 32m), 12 in (since 32m)
    rgw: 4 daemons active (4 hosts, 2 zones)
 
  data:
    pools:   10 pools, 289 pgs
    objects: 424 objects, 467 KiB
    usage:   879 MiB used, 66 GiB / 67 GiB avail
    pgs:     289 active+clean
~~~

## k0s pour rook-ceph

~~~bash
# for N in {0..6}; do ssh-keygen -f /home/$USER/.ssh/known_hosts -R 192.168.56.14${N}; done
# On install k0sctl si on ne l'a pas
sudo curl -fLo /usr/local/bin/k0sctl --create-dirs https://github.com/k0sproject/k0sctl/releases/download/v0.27.0/k0sctl-linux-amd64 && sudo chmod 755 /usr/local/bin/k0sctl
# On fabrique le fichier de configuration
k0sctl init --cluster-name k0s-cluster --controller-count 3 --user myadmin --key-path $(pwd)/roles/ansible_role_libvirt_client_configure/files/id_ed25519 myadmin@192.168.56.141 myadmin@192.168.56.142 myadmin@192.168.56.143 myadmin@192.168.56.144 myadmin@192.168.56.145 myadmin@192.168.56.146 > myk0scluster.yaml
# On charge la clef pour faire apply
ssh-add $(pwd)/roles/ansible_role_libvirt_client_configure/files/id_ed25519
# On lance l'installation avec le fichier de configuration qui a été crée
k0sctl apply --config myk0scluster.yaml --debug
# On recupère le kubeconfig pour kubectl
k0sctl kubeconfig --config myk0scluster.yaml > ~/.kube/k0s-kubeconfig && export KUBECONFIG=~/.kube/k0s-kubeconfig && kubectl get all -A
# On supprime tout, un 'vagrant destroy -f' fait aussi l'affaire.
k0sctl reset --config myk0scluster.yaml --debug

for i in {1..4}; do
  echo "Restart node$i..."
  vagrant ssh node$i -c "ls -la /var/lib/k0s/kubelet"
done
~~~

## Rook-Ceph

## Rook-Ceph avec 'git clone' (ne fonctionne pas !)

Puis on suit

[https://rook.io/docs/rook/v1.9/quickstart.html](https://rook.io/docs/rook/v1.9/quickstart.html)
[https://docs.k0sproject.io/v1.30.5+k0s.0/examples/rook-ceph/](https://docs.k0sproject.io/v1.30.5+k0s.0/examples/rook-ceph/)
[https://rook.io/docs/rook/latest-release/Helm-Charts/operator-chart/#configuration](https://rook.io/docs/rook/latest-release/Helm-Charts/operator-chart/#configuration)

C'est à dire faire ce qui suit. C'est une opération très longue.

~~~bash
git clone --single-branch --branch v1.18.8 https://github.com/rook/rook.git
cd rook/deploy/examples
export KUBECONFIG=~/.kube/k0s-kubeconfig
kubectl create -f crds.yaml -f common.yaml -f operator.yaml

# operator.yaml ligne 507 mettre à true comme :
# 156 ROOK_CSI_KUBELET_DIR_PATH: "/var/lib/k0s/kubelet"
# 507 ROOK_ENABLE_DISCOVERY_DAEMON: "true"
kubectl create -f operator.yaml

# cluster.yaml, ligne 116 mettre 'provider: host' actif, donc enlever le #
# provider: host
kubectl create -f cluster.yaml

kubectl -n rook-ceph events -w

kubectl delete -f cluster.yaml -f crds.yaml -f common.yaml -f operator.yaml
kubectl delete namespace rook-ceph --all

for i in {1..6}; do
  echo "Restart node$i..."
  vagrant ssh node$i -c "sudo shutdown -r now"
done
~~~

## Rook-Ceph avec helm (ne fonctionne pas !)

Installation de prometheus

~~~bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm show values prometheus-community/kube-prometheus-stack
helm upgrade --install prometheus --namespace prometheus --create-namespace prometheus-community/kube-prometheus-stack --version 79.9.0
# Get Grafana 'admin' user password by running:
kubectl --namespace prometheus get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
# Access Grafana local instance:
export POD_NAME=$(kubectl --namespace prometheus get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
kubectl --namespace prometheus port-forward $POD_NAME 3000
# Get your grafana admin user password by running:
kubectl get secret --namespace prometheus -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo
~~~

Déinstallation de prometheus

~~~bash
helm uninstall prometheus
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd probes.monitoring.coreos.com
kubectl delete crd prometheusagents.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd scrapeconfigs.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com
~~~

~~~bash
source ~/venv/bin/activate && export KUBECONFIG=~/.kube/k0s-kubeconfig
helm repo add rook-release https://charts.rook.io/release && helm repo update
helm search repo rook-release/rook-ceph --versions | head -n 5
helm show values rook-release/rook-ceph --version v1.18.8 > ~/tmp/values.yaml
helm upgrade --install --namespace rook-ceph --create-namespace rook-ceph rook-release/rook-ceph --version v1.18.8 \
  --set csi.kubeletDirPath=/var/lib/k0s/kubelet
~~~

~~~bash
helm repo add rook-release https://charts.rook.io/release
helm search repo rook-release/rook-ceph-cluster --versions | head -n 5
helm show values rook-release/rook-ceph-cluster --version v1.18.8 > ~/tmp/values.yaml
helm upgrade --install --namespace rook-ceph --create-namespace rook-ceph-cluster rook-release/rook-ceph-cluster --version v1.18.8 \
  --set toolbox.enabled=true \
  --set monitoring.enabled=true \
  --set cephClusterSpec.dataDirHostPath=/var/lib/rook \
  --set cephClusterSpec.mgr.count=1 \
  --set cephClusterSpec.resources.osd.requests.memory=1Gi \
  --set cephClusterSpec.resources.osd.limits.memory=3Gi \
  --set cephClusterSpec.storage.useAllNodes=true \
  --set cephClusterSpec.storage.useAllDevices=false \
  --set cephClusterSpec.storage.devices=["vdb","vdc"] \
  --set cephClusterSpec.storage.config.osdsPerDevice=1 \
  --set cephClusterSpec.storage.config.databaseSizeMB=1024

helm upgrade --install --namespace rook-ceph --create-namespace rook-ceph-cluster rook-release/rook-ceph-cluster --version v1.18.8 -f rook-cluster-values.yaml

kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

helm uninstall --namespace rook-ceph rook-ceph-cluster
kubectl delete namespace rook-ceph
~~~

~~~bash
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- bash
~~~

~~~bash
bash-5.1$ ceph status
...
bash-5.1$ ceph health
HEALTH_ERR 1 filesystem is offline; 1 filesystem is online with fewer MDS than max_mds; Reduced data availability: 60 pgs inactive
bash-5.1$ ceph osd status
ID  HOST   USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE      
 0           0      0       0        0       0        0   exists,up  
 1           0      0       0        0       0        0   exists,up  
 2           0      0       0        0       0        0   exists,up  
 3           0      0       0        0       0        0   exists,up  
 4           0      0       0        0       0        0   exists,up  
 5           0      0       0        0       0        0   exists,up
bash-5.1$ ceph osd tree
ID  CLASS  WEIGHT  TYPE NAME     STATUS  REWEIGHT  PRI-AFF
-1              0  root default                           
 0              0  osd.0           down         0  1.00000
 1              0  osd.1           down         0  1.00000
 2              0  osd.2           down   1.00000  1.00000
 3              0  osd.3           down   1.00000  1.00000
 4              0  osd.4           down   1.00000  1.00000
 5              0  osd.5           down   1.00000  1.00000
~~~

~~~bash
source ~/venv/bin/activate && export KUBECONFIG=~/.kube/k0s-kubeconfig
kubectl api-resources --verbs=list --namespaced=true -o name | xargs -n 1 kubectl get --ignore-not-found --show-kind -n rook-ceph

# https://rook.io/docs/rook/latest-release/Storage-Configuration/ceph-teardown/#removing-the-cluster-crd-finalizer
kubectl patch -n rook-ceph clientprofile.csi.ceph.io rook-ceph -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph cephobjectstore.ceph.rook.io/ceph-objectstore -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph cephfilesystemsubvolumegroup.ceph.rook.io/ceph-filesystem-csi -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph cephfilesystem.ceph.rook.io/ceph-filesystem -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph cephcluster.ceph.rook.io/rook-ceph -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph cephblockpool.ceph.rook.io/ceph-blockpool -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph secret/rook-ceph-mon -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-ceph configmap/rook-ceph-mon-endpoints -p '{"metadata":{"finalizers":[]}}' --type=merge

for i in {1..4}; do
  vagrant ssh node$i -c "sudo rm -rf /var/lib/k0s/kubelet/rook-ceph"
  vagrant ssh node$i -c "sudo wipefs -a /dev/vd[b,c]"
done
~~~

## OpenESB

~~~bash
helm repo add openebs https://openebs.github.io/openebs
helm repo update
helm search repo openebs/openebs --versions | head -n 5
helm show values openebs/openebs --version 4.4.0

helm upgrade --install openebs --namespace openebs --create-namespace --version 4.4.0 openebs/openebs \
  --set lvm-localpv.lvmNode.kubeletDir=/var/lib/k0s/kubelet \
  --set zfs-localpv.zfsNode.kubeletDir=/var/lib/k0s/kubelet \
  --set mayastor.csi.node.kubeletDir=/var/lib/k0s/kubelet \
  --set engines.replicated.mayastor.enabled=false

helm upgrade --install openebs --namespace openebs --create-namespace --version 4.4.0 openebs/openebs \
  --set lvm-localpv.lvmNode.kubeletDir=/var/lib/k0s/kubelet \
  --set zfs-localpv.zfsNode.kubeletDir=/var/lib/k0s/kubelet \
  --set mayastor.csi.node.kubeletDir=/var/lib/k0s/kubelet

kubectl get storageclass
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

cat <<EOF | kubectl apply -f -
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: local-hostpath-pvc
spec:
  storageClassName: openebs-hostpath
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G
---
apiVersion: v1
kind: Pod
metadata:
  name: hello-local-hostpath-pod
spec:
  volumes:
  - name: local-storage
    persistentVolumeClaim:
      claimName: local-hostpath-pvc
  containers:
  - name: hello-container
    image: ubuntu:latest
    imagePullPolicy: IfNotPresent
    command: ["/bin/sleep", "7d"]
    volumeMounts:
    - mountPath: /mnt/store
      name: local-storage
EOF
kubectl exec -it hello-local-hostpath-pod -- /bin/bash


helm uninstall -n openebs openebs
~~~

## Short list

~~~bash
# On a besoin de ansible
source ~/venv/bin/activate
vagrant up --provision --provider=libvirt
# L'installation avec k0sctl ne fonctionne pas si ~/.ssh/known_hosts ne référence pas bien les vm et il lui faut la clef ed25519
for N in {0..6}; do ssh-keygen -f /home/$USER/.ssh/known_hosts -R 192.168.56.14${N}; done
ssh-add $(pwd)/roles/ansible_role_libvirt_client_configure/files/id_ed25519
k0sctl apply --config myk0scluster.yaml
# On récupère tout de suite le kubeconfig
k0sctl kubeconfig --config myk0scluster.yaml > ~/.kube/k0s-kubeconfig && export KUBECONFIG=~/.kube/k0s-kubeconfig && kubectl get all -A && kubectl top nodes
helm repo update
helm upgrade --install prometheus --namespace prometheus --create-namespace prometheus-community/kube-prometheus-stack --version 79.9.0
# Get Grafana 'admin' user password by running:
kubectl --namespace prometheus get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
helm upgrade --install --namespace rook-ceph --create-namespace rook-ceph rook-release/rook-ceph --version v1.18.8 \
  --set csi.kubeletDirPath=/var/lib/k0s/kubelet
helm upgrade --install --namespace rook-ceph --create-namespace rook-ceph-cluster rook-release/rook-ceph-cluster --version v1.18.8 --values rook-cluster-values.yaml
~~~

Netoyage de rook-ceph

~~~bash
source ~/venv/bin/activate && export KUBECONFIG=~/.kube/k0s-kubeconfig
helm ls --namespace rook-ceph
helm delete --namespace rook-ceph rook-ceph
for CRD in $(kubectl get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do
    kubectl get -n rook-ceph "$CRD" -o name | \
    xargs -I {} kubectl patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": []}}'
done

kubectl delete namespaces rook-ceph
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n rook-ceph
kubectl -n rook-ceph patch configmap rook-ceph-mon-endpoints --type merge -p '{"metadata":{"finalizers": []}}'
kubectl -n rook-ceph patch secrets rook-ceph-mon --type merge -p '{"metadata":{"finalizers": []}}'
kubectl -n rook-ceph patch clientprofile.csi.ceph.io rook-ceph --type merge -p '{"metadata":{"finalizers": []}}'

kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get -n rook-ceph --ignore-not-found -o json \
  | jq -r '.items[] | [.kind, .metadata.name] | @tsv' \
  | while read kind name; do
      kubectl -n rook-ceph patch "$kind" "$name" \
        --type merge -p '{"metadata":{"finalizers":[]}}'
    done

for i in {1..4}; do
  vagrant ssh node$i -c "sudo rm -rf /var/lib/k0s/kubelet/rook-ceph"
  vagrant ssh node$i -c "sudo rm -rf /var/lib/rook"
  vagrant ssh node$i -c "sudo wipefs -a /dev/vd[b,c]"
done
for i in {1..4}; do vagrant ssh node$i -c "sudo shutdown -r now"; done
~~~
for i in {1..4}; do
  vagrant ssh node$i -c "sudo ls -la /var/lib/k0s/kubelet"
  vagrant ssh node$i -c "sudo ls -la /var/lib"
done

~~~bash
cat <<EOF | kubectl apply -f -
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: "ubuntu-pvc"
spec:
  storageClassName: "ceph-block"
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 400M
EOF
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu
spec:
  volumes:
  - name: local-storage
    persistentVolumeClaim:
      claimName: "ubuntu-pvc"
  containers:
  - name: hello-container
    image: ubuntu:24.04
    imagePullPolicy: IfNotPresent
    command: ["/bin/sleep", "7d"]
    volumeMounts:
    - mountPath: /mnt/store
      name: local-storage
EOF

kubectl exec -it ubuntu -- /bin/bash
echo "mon test" $(LC_ALL=C tr -dc '[:alnum:]' </dev/urandom | head -c 20) > /mnt/store/monfichier.txt

~~~
