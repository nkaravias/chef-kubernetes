#node_file=(command("find /tmp/kitchen/nodes/ -name *.json").stdout)
#node=JSON.parse(command("cat #{node_file}").stdout)
#node=node['default'].merge!(node['override'])

describe package('etcd-elq') do
  it { should be_installed }
end

describe systemd_service('etcd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

#describe port(node['skynet']['etcd']['client_port']) do
[ 2379, 2380 ].each do |etcd_port|
  describe port(etcd_port) do 
    it { should be_listening }
    its('processes') { should include 'etcd' }
    its('protocols') { should include 'tcp' }
  end
end
