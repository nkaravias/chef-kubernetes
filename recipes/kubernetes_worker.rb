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
  action :disable
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
