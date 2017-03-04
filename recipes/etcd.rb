#
# Cookbook Name:: skynet
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
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
