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

yum_package 'kubernetes-master-elq' do
  version node['skynet']['kubernetes']['version']
  action :install
end

if node['skynet']['kubernetes']['master']['certificate_data_bag_info'].empty?
 Chef::Log.info("No certificate information is set - Skipping certificate rendering on this node")
else 
  node['skynet']['kubernetes']['master']['certificate_data_bag_info'].each do |kube_cert|
    dbag = kube_cert['dbag_name']
    dbag_item = kube_cert['dbag_item']
    dbag_key = kube_cert['key']
    cert_path = kube_cert['path']
    Chef::Log.info("Attempting to load #{dbag}::#{dbag_item}::#{dbag_key}")
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

# if the attributes for the controller or scheduler 'master' are empty 
#   if ::api[insecure-bind-address] is localhost or 127.0.0.1 override with http://127.0.0.1 
#   Otherwise override with http://fqdn:['insecure-api-port']
# defaults should be emtpy and overriden if needed by a role
%W{ scheduler cmanager }.each do |svc|
 if node['skynet']['kubernetes']['master'][svc]['master'].empty?
    if ['127.0.0.1', 'localhost'].include? node['skynet']['kubernetes']['master']['api']['insecure-bind-address'] 
      master_uri="http://#{node['skynet']['kubernetes']['master']['api']['insecure-bind-address']}:#{node['skynet']['kubernetes']['master']['api']['insecure-port']}"
    else
      master_uri="http://#{node['fqdn']}:#{node['skynet']['kubernetes']['master']['api']['insecure-port']}"
    end
    Chef::Log.info("The master attribute is not set for the #{svc}: overriding with #{master_uri}")
    node.override['skynet']['kubernetes']['master'][svc]['master']=master_uri
  end
end



#If api['authorization-policy-file'] is set load the values from a data bag and render the file 
# If api['token-auth-file'] is set load the values from a data bag and render the file 
#[{dbag_info: "auth_policy_data_bag_info", config_attr: "authorization-policy-file"},
[{dbag_info: "token_data_bag_info", config_attr: "token-auth-file"}].collect { |cfg|
   unless node['skynet']['kubernetes']['master']['api']["#{cfg[:config_attr]}"].empty?
    if node['skynet']['kubernetes']['master']["#{cfg[:dbag_info]}"].empty?
      Chef::Log.error("Missing data bag configuration. Check node['skynet']['kubernetes']['master'][#{cfg[:dbag_info]}]")
      raise "node['skynet']['kubernetes']['master'][#{cfg[:dbag_info]}].empty?"
    else
      dbag = node['skynet']['kubernetes']['master'][cfg[:dbag_info]].keys.first
      dbag_item = node['skynet']['kubernetes']['master'][cfg[:dbag_info]][dbag]
      Chef::Log.info("Attempting to load #{dbag}::#{dbag_item} - Attribute #{cfg[:config_attr]} is set") 
      if cfg[:config_attr] == 'token-auth-file' 
	mappings = Chef::EncryptedDataBagItem.load(dbag, dbag_item)['token_mappings']
        template_file='token.csv.erb'  
      elsif cfg[:config_attr] == 'authorization-policy-file'
        mappings = Chef::EncryptedDataBagItem.load(dbag, dbag_item)['policies']
        template_file='authorization-policy.jsonl.erb'
      else
        raise "unsupported value: #{cfg}"
      end
      template node['skynet']['kubernetes']['master']['api']["#{cfg[:config_attr]}"] do
        source ::File.join("var/lib/kubernetes",template_file)
        owner node['skynet']['kubernetes']['user']
        group node['skynet']['kubernetes']['group']
        mode "0700"
        helpers(Skynet::SkynetHelper)
        cookbook 'skynet'
        variables(:mappings => mappings)
        notifies :run, "execute[systemctl daemon-reload]", :delayed
        notifies :restart, "service[kube-apiserver]", :delayed
        notifies :restart, "service[kube-controller-manager]", :delayed
        notifies :restart, "service[kube-scheduler]", :delayed
      end
    end
  end
}

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

%W{ kube-apiserver kube-controller-manager kube-scheduler }.each do |k8s_svc|
  template "/etc/systemd/system/#{k8s_svc}.service" do
    source "etc/systemd/system/#{k8s_svc}.service.erb"
    owner node['skynet']['kubernetes']['user'] 
    group node['skynet']['kubernetes']['group']
    mode '0644'
    helpers(Skynet::SkynetHelper)
    cookbook 'skynet'
    variables(:kube_master_config => node['skynet']['kubernetes']['master'])
    notifies :run, "execute[systemctl daemon-reload]", :delayed
    notifies :restart, "service[#{k8s_svc}]", :delayed
  end

  service k8s_svc do
    action [:enable]
  end
end
