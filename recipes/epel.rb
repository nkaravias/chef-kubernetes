remote_file ::File.join(Chef::Config[:file_cache_path],'epel-release-latest-7.noarch.rpm') do
  source 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'
end

yum_package 'epel-release-latest-7.noarch.rpm' do
  source ::File.join(Chef::Config[:file_cache_path],'epel-release-latest-7.noarch.rpm')
end

node['skynet']['core']['pkgs'].each do |pkg,version|
  if version.empty?
    yum_package pkg do
      notifies :run, 'execute[disable epel]'
    end
  else
    yum_package pkg do
      version version
      notifies :run, 'execute[disable epel]'
    end
  end
end

execute 'disable epel' do
  cwd '/etc/yum.repos.d'
  command 'sed -i s/enabled=1/enabled=0/g epel.repo'
  action :nothing
end
