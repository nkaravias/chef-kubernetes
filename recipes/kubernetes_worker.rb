yum_repository "oradev_repository" do
  description "oradev repository"
  baseurl node['skynet']['yum']['oradev']['base_url']
  gpgkey node['skynet']['yum']['oradev']['gpg_key_url']
  gpgcheck node['skynet']['yum']['oradev']['gpgcheck']
  action :create
end

# Install/configure kubelet
yum_package 'kubernetes-worker-elq' do
  version node['skynet']['kubernetes']['worker']['version']
  action :install
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
  notifies :nothing, "execute[systemctl daemon-reload]", :delayed
  notifies :nothing, "service[kubelet]", :delayed
end

template '/etc/kubernetes/kubeconfig' do
  owner node['skynet']['kubernetes']['user']
  group node['skynet']['kubernetes']['group']
  source 'default/etc/kubernetes/kubeconfig.erb'
  mode '0700'
  helpers(Skynet::SkynetHelper)
  cookbook 'skynet'
  variables(:kube_worker_config => node['skynet']['kubernetes']['worker'])
  notifies :nothing, "execute[systemctl daemon-reload]", :delayed
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
  notifies :nothing, "execute[systemctl daemon-reload]", :delayed
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

# Install/configure flanneld
yum_package 'flanneld-elq' do
  action :install
end

template '/etc/sysconfig/flanneld' do 
  source 'default/etc/sysconfig/flanneld.erb'
  variables(:flannel_etcd_uri => node['skynet']['kubernetes']['worker']['flanneld']['etcd_uri'], :flannel_etcd_key => node['skynet']['kubernetes']['worker']['flanneld']['etcd_key'])
  action :create
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'flanneld' do
  action :nothing
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

  service 'flanneld' do
    action [:enable]
  end

end

service 'kubelet' do
  action :nothing
end

service 'kube-proxy' do
  action :nothing
end
