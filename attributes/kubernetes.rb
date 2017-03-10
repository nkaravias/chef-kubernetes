default['skynet']['kubernetes']['user']='root'
default['skynet']['kubernetes']['group']='root'

default['skynet']['kubernetes']['version']='1.5.2-1'
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
  api['service-cluster-ip-range']='172.16.0.0/16'
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
  cmanager['cluster-name']='kubernetes'
  cmanager['leader-elect']=true
  cmanager['master']=''
  cmanager['root-ca-file']='/etc/kubernetes/sky-ca.pem'
  cmanager['service-account-private-key-file']='/etc/kubernetes/sky-kubernetes-key.pem'
  cmanager['service-cluster-ip-range']='172.16.0.0/16'
  cmanager['cluster-signing-cert-file']='/etc/kubernetes/sky-ca.pem'
  cmanager['cluster-signing-key-file']='/etc/kubernetes/sky-ca-key.pem'
end
