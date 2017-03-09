#
# Cookbook Name:: skynet
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
::Chef::Recipe.send(:include,Skynet::SkynetHelper)

yum_repository "oradev_repository" do
  description "oradev repository"
  baseurl node['skynet']['yum']['oradev']['base_url']
  gpgkey node['skynet']['yum']['oradev']['gpg_key_url']
  gpgcheck node['skynet']['yum']['oradev']['gpgcheck']
  action :create
end

yum_package 'etcd-elq' do
  version node['skynet']['etcd']['version']
  action :install
end

# if attribute is empty use FQDN fqdn and tls_enabled to override the config
if node['skynet']['etcd']['name'].empty? 
  Chef::Log.info("#{'name'} is set to #{node['hostname']}")
  node.override['skynet']['etcd']['name']=node['hostname']
end

#if any of the attributes in the list are empty generate the config automatically
# otherwise use a role on a per node basis to override on each applicable node
%W{ initial-advertise-peer-urls listen-peer-urls }.each do |etcd_attr|
  if node['skynet']['etcd'][etcd_attr].empty?
    peer_host_url=get_etcd_url(node['fqdn'],node['skynet']['etcd']['peer_port'],node['skynet']['etcd']['tls_enabled'])
    Chef::Log.info("Setting #{etcd_attr} to #{peer_host_url}")
    node.override['skynet']['etcd'][etcd_attr]=peer_host_url
  else
    Chef::Log.info("Default found for #{etcd_attr} = #{node['skynet']['etcd'][etcd_attr]}")
  end
end

%W{ listen-client-urls advertise-client-urls }.each do |etcd_attr|
  if node['skynet']['etcd'][etcd_attr].empty?
    client_host_url=get_etcd_url(node['fqdn'],node['skynet']['etcd']['client_port'],node['skynet']['etcd']['tls_enabled'])
    Chef::Log.info("Setting #{etcd_attr} to #{client_host_url}")
    node.override['skynet']['etcd'][etcd_attr]=client_host_url
  else
    Chef::Log.info("Default found for #{etcd_attr} = #{node['skynet']['etcd'][etcd_attr]}")
  end
end

if node['skynet']['etcd']['certificate_data_bag_info'].empty?
 Chef::Log.info("No certificate information is set - Skipping certificate rendering on this node")
else 
  node['skynet']['etcd']['certificate_data_bag_info'].each do |etcd_cert|
    dbag = etcd_cert['dbag_name']
    dbag_item = etcd_cert['dbag_item']
    dbag_key = etcd_cert['key']
    cert_path = etcd_cert['path']
    Chef::Log.info("Attempting to load #{dbag}::#{dbag_item}::#{dbag_key}")
    dbag_obj = Chef::EncryptedDataBagItem.load(dbag, dbag_item)
    file dbag_key do
      path cert_path
      owner node['skynet']['etcd']['user']
      group node['skynet']['etcd']['group']
      mode '0700'
      content Base64.decode64(dbag_obj[dbag_key])      
    end
  end
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/etc/systemd/system/etcd.service' do
  source 'etc/systemd/system/etcd.service.erb'
  owner node['skynet']['etcd']['user'] 
  group node['skynet']['etcd']['group']
  mode '0644'
  helpers(Skynet::SkynetHelper)
  cookbook'skynet'
  variables(:etcd_config => node['skynet']['etcd'])
  notifies :run, "execute[systemctl daemon-reload]", :delayed
  notifies :restart, "service[etcd]", :delayed
end

service 'etcd' do
  action [:enable]
end
