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
default['skynet']['etcd']['cert-file']=''
default['skynet']['etcd']['key-file']=''
default['skynet']['etcd']['peer-cert-file']=''
default['skynet']['etcd']['peer-key-file']=''
default['skynet']['etcd']['trusted-ca-file']=''
default['skynet']['etcd']['peer-trusted-ca-file']=''
default['skynet']['etcd']['initial-advertise-peer-urls']='http://localhost:2380'
default['skynet']['etcd']['listen-peer-urls']='http://localhost:2380'
default['skynet']['etcd']['listen-client-urls']='http://localhost:2379'
default['skynet']['etcd']['advertise-client-urls']='http://localhost:2379'
default['skynet']['etcd']['initial-cluster-token']='etcd-cluster-0'
default['skynet']['etcd']['initial-cluster']="localnode=http://localhost:2380"
default['skynet']['etcd']['initial-cluster-state']='new'
default['skynet']['etcd']['data-dir']='/var/lib/etcd'

=begin
 --initial-cluster den00hmj=https://den00hmj.us.oracle.com:2380,den00hmg=https://den00hmg.us.oracle.com:2380,den00hmi=https://den00hmi.us.oracle.com:2380 \
=end
