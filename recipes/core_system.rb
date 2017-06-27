template '/etc/yum.conf' do
  source 'default/etc/yum.conf.erb'
  variables(:core => node['skynet']['core'])
end

node.default['chef_client']['config']['http_proxy']=node['skynet']['core']['proxy']['http'] 
node.default['chef_client']['config']['https_proxy']=node['skynet']['core']['proxy']['https'] 
node.default['chef_client']['config']['no_proxy']=node['skynet']['core']['proxy']['no'] 

include_recipe 'skynet::epel'
include_recipe 'chef-client::config'
