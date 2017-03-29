default['skynet']['kubernetes']['user']='root'
default['skynet']['kubernetes']['group']='root'

default['skynet']['kubernetes']['version']='1.5.2-1'
default['skynet']['kubernetes']['worker']['version']='1.5.2-1'
#default['skynet']['docker']['version']='1.12.6-1.el7'
default['skynet']['docker']['version']='1.12.3-1.el7'

# Master configuration
default['skynet']['kubernetes']['master']['certificate_data_bag_info']=[]
default['skynet']['kubernetes']['master']['token_data_bag_info']={}
default['skynet']['kubernetes']['master']['auth_policy_data_bag_info']={}
default['skynet']['kubernetes']['master']['data_path']='/var/lib/kubernetes'

default['skynet']['kubernetes']['master']['api'].tap do |api|
  api['admission-control']='NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota'
  api['allow-privileged']=true
  api['apiserver-count']=1
  api['authorization-mode']='ABAC'
  api['authorization-policy-file']=''
  api['bind-address']='0.0.0.0'
  api['secure-port']=6443
  api['insecure-port']=8080
  api['insecure-bind-address']='127.0.0.1'
  api['enable-swagger-ui']=true
  api['etcd-cafile']='/etc/kubernetes/sky-ca.pem'
  api['kubelet-certificate-authority']='/etc/kubernetes/sky-ca.pem'
  api['etcd-servers']="https://default-chef12:2379"
  api['service-account-key-file']='/etc/kubernetes/sky-kubernetes-key.pem'
  api['service-cluster-ip-range']='172.16.0.0/24'
  api['tls-cert-file']='/etc/kubernetes/sky-kubernetes.pem'
  api['tls-private-key-file']='/etc/kubernetes/sky-kubernetes-key.pem'
  api['token-auth-file']=''
end

default['skynet']['kubernetes']['master']['scheduler'].tap do |scheduler|
  scheduler['leader-elect']=true
  scheduler['master']=''
end

default['skynet']['kubernetes']['master']['cmanager'].tap do |cmanager|
  cmanager['allocate-node-cidrs']=true
  cmanager['cluster-cidr']='172.16.0.0/16'
  cmanager['node-cidr-mask-size']=24
  cmanager['cluster-name']='kubernetes'
  cmanager['leader-elect']=true
  cmanager['master']=''
  cmanager['root-ca-file']='/etc/kubernetes/sky-ca.pem'
  cmanager['service-account-private-key-file']='/etc/kubernetes/sky-kubernetes-key.pem'
  cmanager['service-cluster-ip-range']='172.16.0.0/16'
  cmanager['cluster-signing-cert-file']='/etc/kubernetes/sky-ca.pem'
  cmanager['cluster-signing-key-file']='/etc/kubernetes/sky-ca-key.pem'
end

# Worker configuration
default['skynet']['kubernetes']['worker']['certificate_data_bag_info']=[]
default['skynet']['kubernetes']['worker']['flanneld'].tap do |flanneld|
  flanneld['etcd_uri']=''#"https://default-chef12:2379"
  flanneld['etcd_key']=''#'/skynet/network'
end

default['skynet']['kubernetes']['worker']['kubelet'].tap do |kubelet|
  kubelet['allow-privileged']=true
  kubelet['api-servers']=''
  kubelet['require-kubeconfig']=true
  kubelet['cluster-dns']='172.16.0.10'
  kubelet['cluster-domain']='cluster.local'
  kubelet['container-runtime']='docker'
  kubelet['cni-conf-dir']='/etc/cni/net.d' 
  kubelet['network-plugin']='cni' 
  kubelet['network-plugin-mtu']=1450 
  kubelet['docker']='unix:///var/run/docker.sock'
  kubelet['kubeconfig']='/etc/kubernetes/kubeconfig'
  kubelet['cert-dir']='/etc/kubernetes'
  kubelet['tls-cert-file']='/etc/kubernetes/sky-kubelet.pem'
  kubelet['tls-private-key-file']='/etc/kubernetes/sky-kubelet-key.pem'
  kubelet['client-ca-file']='/etc/kubernetes/sky-ca.pem'
  kubelet['serialize-image-pulls']=false 
end

default['skynet']['kubernetes']['worker']['kube-proxy'].tap do |proxy|
  proxy['kubeconfig']='/etc/kubernetes/kubeconfig'
  proxy['cluster-cidr']='172.16.0.0/16'
  proxy['proxy-mode']='iptables'
end

#default['skynet']['kubernetes']['worker']['kubeconfig'].tap do |proxy|
#
#end
default['skynet']['kubernetes']['worker']['cni'].tap do |cni|
  cni['bin_dir']='/opt/cni/bin'
  cni['conf_dir']='/etc/cni/net.d'
  cni['plugin_url']='https://github.com/containernetworking/cni/releases/download/v0.5.1/cni-amd64-v0.5.1.tgz'
end


