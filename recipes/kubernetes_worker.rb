yum_repository "sky-elq" do
  description "skynet-elq repository"
  baseurl node['skynet']['yum']['elqrepo']['base_url']
  gpgkey node['skynet']['yum']['elqrepo']['gpg_key_url']
  gpgcheck node['skynet']['yum']['elqrepo']['gpgcheck']
  action :create
end
# Install/configure kubelet
yum_package 'kubernetes-worker-elq' do
  version node['skynet']['kubernetes']['worker']['version']
  action :install
end

# render kubeconfigs for kubelet (bootstrap only) and kube-proxy
if node['skynet']['kubernetes']['worker']['certificate_data_bag_info'].empty?
  Chef::Log.info("No certificate information is set for the worker - Skipping certificate kubeconfig rendering on this node")
else
  certificate_data_bag_info = node['skynet']['kubernetes']['worker']['certificate_data_bag_info']
  ca_cert_data = certificate_data_bag_info.select{ |cert_data| cert_data[:key] == 'ca.cert'}
  kube_proxy_client_cert_data = certificate_data_bag_info.select{ |cert_data| cert_data[:key] == 'kube.proxy.client.cert'}
  kube_proxy_client_cert_key_data = certificate_data_bag_info.select{ |cert_data| cert_data[:key] == 'kube.proxy.client.key'}
  ca_certificate_base64 = Chef::EncryptedDataBagItem.load(ca_cert_data.first['dbag_name'], ca_cert_data.first['dbag_item'])['ca.cert']
  kube_proxy_client_certificate_base64 = Chef::EncryptedDataBagItem.load(kube_proxy_client_cert_data.first['dbag_name'], kube_proxy_client_cert_data.first['dbag_item'])['kube.proxy.client.cert']
  kube_proxy_client_certificate_key_base64 = Chef::EncryptedDataBagItem.load(kube_proxy_client_cert_key_data.first['dbag_name'], kube_proxy_client_cert_key_data.first['dbag_item'])['kube.proxy.client.key']
  token_data_bag_info = node['skynet']['kubernetes']['master']['token_data_bag_info']
  bootstrap_token = Chef::EncryptedDataBagItem.load(token_data_bag_info.keys.first,token_data_bag_info[token_data_bag_info.keys.first])['token_mappings'].first['token']

  if node['skynet']['kubernetes']['worker']['api-endpoints'].empty?
    Chef::Log.info("No attribute set for node['skynet']['kubernetes']['worker']['api-endpoints']")
    Chef::Log.info("Leveraging search for tags:#{node['skynet']['kubernetes']['master']['api']['chef-tag']} and chef_environment:#{node[:environment]}")
    api_servers = search(:node, 'tags:eloqua-sky-master')
    api_endpoints=[]
    api_servers.each do |server|
      api_endpoints.push("https://#{server['fqdn']}:#{node['skynet']['kubernetes']['master']['api']['secure-port']}")
    end
  else
   api_endpoints = node['skynet']['kubernetes']['worker']['api-endpoints']
  end
  template '/var/lib/kubelet/kubeconfig.bootstrap' do
    owner node['skynet']['kubernetes']['user']
    group node['skynet']['kubernetes']['group']
    source 'default/var/lib/kubelet/kubeconfig.bootstrap.erb'
    mode '0700'
    helpers(Skynet::SkynetHelper)
    cookbook 'skynet'
    variables(:ca_certificate_base64 => ca_certificate_base64, :cluster_name => node['skynet']['kubernetes']['master']['cmanager']['cluster-name'], :bootstrap_token => bootstrap_token, :servers => api_endpoints)
  end
  template '/var/lib/kube-proxy/kubeconfig.kube-proxy' do
    owner node['skynet']['kubernetes']['user']
    group node['skynet']['kubernetes']['group']
    source 'default/var/lib/kube-proxy/kubeconfig.kube-proxy.erb'
    mode '0700'
    helpers(Skynet::SkynetHelper)
    cookbook 'skynet'
    variables(:ca_certificate_base64 => ca_certificate_base64, :cluster_name => node['skynet']['kubernetes']['master']['cmanager']['cluster-name'], :servers => api_endpoints, :kube_proxy_client_certificate_base64 => kube_proxy_client_certificate_base64, :kube_proxy_client_certificate_key_base64 => kube_proxy_client_certificate_key_base64)
  end
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/etc/systemd/system/kubelet.service' do
  owner node['skynet']['kubernetes']['user']
  group node['skynet']['kubernetes']['group']
  source 'default/etc/systemd/system/kubelet.service.erb'
  mode '0700'
  helpers(Skynet::SkynetHelper)
  cookbook 'skynet'
  variables(:kube_worker_config => node['skynet']['kubernetes']['worker'])
  notifies :run, "execute[systemctl daemon-reload]", :delayed
  notifies :nothing, "service[kubelet]", :delayed
end

template '/etc/systemd/system/kube-proxy.service' do
  owner node['skynet']['kubernetes']['user']
  group node['skynet']['kubernetes']['group']
  source 'default/etc/systemd/system/kube-proxy.service.erb'
  mode '0700'
  helpers(Skynet::SkynetHelper)
  cookbook 'skynet'
  variables(:kube_worker_config => node['skynet']['kubernetes']['worker'])
  notifies :run, "execute[systemctl daemon-reload]", :delayed
  notifies :nothing, "service[kube-proxy]", :delayed
end

if node['skynet']['kubernetes']['worker']['certificate_data_bag_info'].empty?
 Chef::Log.info("No certificate information is set for the worker - Skipping certificate rendering on this node")
else
  node['skynet']['kubernetes']['worker']['certificate_data_bag_info'].each do |kube_cert|
    dbag = kube_cert['dbag_name']
    dbag_item = kube_cert['dbag_item']
    dbag_key = kube_cert['key']
    cert_path = kube_cert['path']
    Chef::Log.info("Attempting to load #{dbag}::#{dbag_item}::#{dbag_key} for the worker node")
    dbag_obj = Chef::EncryptedDataBagItem.load(dbag, dbag_item)
    file dbag_key do
      path cert_path
      owner node['skynet']['kubernetes']['user']
      group node['skynet']['kubernetes']['group']
      mode '0700'
      content Base64.decode64(dbag_obj[dbag_key])
    end
  end
end
# Install / configure CNI
yum_package 'cni-elq' do
  version node['skynet']['kubernetes']['worker']['cni']['version']
  action :install
end

template ::File.join(node['skynet']['kubernetes']['worker']['cni']['conf_dir'],'flannel.conf') do
  source 'default/etc/cni/flannel.conf.erb'
  action :create
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

# Install/configure flanneld
yum_package 'flanneld-elq' do
  version node['skynet']['kubernetes']['worker']['flanneld']['version']
  action :install
end

template '/etc/sysconfig/flanneld' do 
  source 'default/etc/sysconfig/flanneld.erb'
  variables(:flannel_etcd_uri => node['skynet']['kubernetes']['worker']['flanneld']['etcd_uri'], :flannel_etcd_key => node['skynet']['kubernetes']['worker']['flanneld']['etcd_key'])
  action :create
end


service 'flanneld' do
  action :enable
end

template "/etc/systemd/system/flanneld.service" do
  source "etc/systemd/system/flanneld.service.erb"
  owner 'root'
  group 'root'
  mode '0644'
  helpers(Skynet::SkynetHelper)
  cookbook 'skynet'
  notifies :run, "execute[systemctl daemon-reload]", :delayed
  #notifies :restart, "service[flanneld]", :delayed
end

# Install/Configure the docker engine
Chef::Log.info("Kernel version detected: #{node[:kernel][:release]}")
=begin
if /^4.*/.match(node[:kernel][:release])
  Chef::Log.info("Kernel version >= 4.x")
  Chef::Log.info("Installing and configuring the docker engine")

  template '/etc/yum.repos.d/docker.repo' do
   source 'etc/yum.repos.d/docker.repo.erb'
  end

  yum_package 'docker-engine' do
    version node['skynet']['docker']['version']
    action :install
  end

  directory '/etc/systemd/system/docker.service.d' do
    recursive true
  end

  template '/etc/systemd/system/docker.service' do
    source 'etc/systemd/system/docker.service.erb'
  end

  template '/etc/systemd/system/docker.service.d/http-proxy.conf' do
    source 'etc/systemd/system/dockerd.http-proxy.conf.erb'
  end

  service 'docker' do
    action [:enable]
  end
end
=end
#service 'flanneld' do
#  action [:enable]
#end

service 'kubelet' do
  action :enable
end

service 'kube-proxy' do
  action :enable
end
