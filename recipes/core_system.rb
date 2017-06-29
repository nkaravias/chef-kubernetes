if node['skynet']['core']['proxy']['yum'].empty?
  proxy_yum=node['skynet']['core']['proxy']['http']
else
  proxy_yum=node['skynet']['core']['proxy']['yum']
end

template '/etc/yum.conf' do
  source 'default/etc/yum.conf.erb'
  variables(:proxy_yum => proxy_yum)
end

ntp_template=node['skynet']['core']['ntp']['use_template']
unless ntp_template.empty?
  template '/etc/ntp.conf' do
    source "default/etc/#{ntp_template}.erb"
  end
end

node.default['chef_client']['config']['http_proxy']=node['skynet']['core']['proxy']['http'] 
node.default['chef_client']['config']['https_proxy']=node['skynet']['core']['proxy']['https'] 
node.default['chef_client']['config']['no_proxy']=node['skynet']['core']['proxy']['no'] 

include_recipe 'chef-client::config'
include_recipe 'skynet::epel'
