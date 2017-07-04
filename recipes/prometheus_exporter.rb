group node['prometheus']['group']

user node['prometheus']['user'] do
  comment     'prometheus daemon'
  gid         node['prometheus']['group']
  home        '/var/empty'
  shell       '/sbin/nologin'
end

yum_repository "oradev_repository" do
  description "oradev repository"
  baseurl node['skynet']['yum']['oradev']['base_url']
  gpgkey node['skynet']['yum']['oradev']['gpg_key_url']
  gpgcheck node['skynet']['yum']['oradev']['gpgcheck']
  action :create
end

unless node['prometheus']['exporter']['node']['package'].empty?
  node['prometheus']['exporter']['node'].tap do |exporter|
    yum_package exporter['package'] do
      version exporter['version']
    end
  end

  template '/etc/sysconfig/node_exporter' do
    source 'default/etc/sysconfig/prometheus_node_exporter.erb'
    owner node['prometheus']['user']
    group node['prometheus']['group']
    variables(:port => node['prometheus']['exporter']['node']['port'], :endpoint => node['prometheus']['exporter']['node']['endpoint'])
  end

  service 'prometheus-node-exporter' do
    action [ :enable, :start ]
    subscribes :restart, 'template[/etc/sysconfig/node_exporter]'
  end
end
