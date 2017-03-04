default['skynet']['etcd']['version']='3.1.2-1'
default['skynet']['yum']['oradev']['gpgcheck']=false
default['skynet']['yum']['oradev']['gpg_key_url']='file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle'
default['skynet']['yum']['oradev']['base_url']='http://den00ake.us.oracle.com/repodata'

default['skynet']['etcd']['user']='etcd'
default['skynet']['etcd']['group']='etcd'
default['skynet']['etcd']['peer_port']=2380
default['skynet']['etcd']['client_port']=2379
default['skynet']['etcd']['name']='localnode'
default['skynet']['etcd']['heartbeat-interval']=200
default['skynet']['etcd']['cert-file']=
default['skynet']['etcd']['key-file']=
default['skynet']['etcd']['peer-cert-file']=
default['skynet']['etcd']['peer-key-file']=
default['skynet']['etcd']['trusted-ca-file']=
default['skynet']['etcd']['peer-trusted-ca-file']=
default['skynet']['etcd']['initial-advertise-peer-urls']=
default['skynet']['etcd']['listen-peer-urls']=
default['skynet']['etcd']['listen-client-urls']=
default['skynet']['etcd']['advertise-client-urls']=
default['skynet']['etcd']['initial-cluster-token']='etcd-cluster-0'
#default['skynet']['etcd']['initial-cluster']="localnode=http://localhost:2380"
default['skynet']['etcd']['initial-cluster-state']='new'
default['skynet']['etcd']['data-dir']='/var/lib/etcd'

=begin

cert
key
ca
peer cert
peer key
peer ca


[Unit]
Description=etcd
Documentation=https://github.com/coreos
[Service]
Type=Notify
NotifyAccess=all
ExecStart=/usr/bin/etcd --name den00hmj \
 --heartbeat-interval=200 \
 --cert-file=/etc/etcd/kubernetes.pem \
 --key-file=/etc/etcd/kubernetes-key.pem \
 --peer-cert-file=/etc/etcd/kubernetes.pem \
 --peer-key-file=/etc/etcd/kubernetes-key.pem \
 --trusted-ca-file=/etc/etcd/ca.pem \
 --peer-trusted-ca-file=/etc/etcd/ca.pem \
 --initial-advertise-peer-urls https://den00hmj.us.oracle.com:2380 \
 --listen-peer-urls https://den00hmj.us.oracle.com:2380 \
 --listen-client-urls https://den00hmj.us.oracle.com:2379 \
 --advertise-client-urls https://den00hmj.us.oracle.com:2379 \
 --initial-cluster-token etcd-cluster-0 \
 --initial-cluster den00hmj=https://den00hmj.us.oracle.com:2380,den00hmg=https://den00hmg.us.oracle.com:2380,den00hmi=https://den00hmi.us.oracle.com:2380 \
 --initial-cluster-state new \
 --data-dir=/var/lib/etcd
#Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
=end
