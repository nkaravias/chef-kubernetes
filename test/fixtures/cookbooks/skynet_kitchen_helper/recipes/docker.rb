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

#  template '/etc/systemd/system/docker.service.d/http-proxy.conf' do
#    source 'etc/systemd/system/dockerd.http-proxy.conf.erb'
#  end

  service 'docker' do
    action [:enable]
  end

end
