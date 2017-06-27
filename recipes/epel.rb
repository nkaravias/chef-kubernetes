remote_file ::File.join(Chef::Config[:file_cache_path],'epel-release-latest-7.noarch.rpm') do
  source 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'
end

yum_package 'epel-release-latest-7.noarch.rpm' do
  source ::File.join(Chef::Config[:file_cache_path],'epel-release-latest-7.noarch.rpm')
end

%W{ ncdu telnet vim nc }.each do |pkg|
  yum_package pkg
end

yum_repository 'epel' do
  enabled false
end
