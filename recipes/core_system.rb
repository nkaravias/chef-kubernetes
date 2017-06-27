if node['skynet']['core']['proxy']['yum'].empty?
  proxy_yum=node['skynet']['core']['proxy']['http']
else
  proxy_yum=node['skynet']['core']['proxy']['yum']
end

template '/etc/yum.conf' do
  source 'default/etc/yum.conf.erb'
  variables(:proxy_yum => proxy_yum)
end

node.default['chef_client']['config']['http_proxy']=node['skynet']['core']['proxy']['http'] 
node.default['chef_client']['config']['https_proxy']=node['skynet']['core']['proxy']['https'] 
node.default['chef_client']['config']['no_proxy']=node['skynet']['core']['proxy']['no'] 

include_recipe 'skynet::epel'
include_recipe 'chef-client::config'
