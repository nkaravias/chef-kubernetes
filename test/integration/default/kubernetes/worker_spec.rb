#node_file=(command("find /tmp/kitchen/nodes/ -name *.json").stdout)
#node=JSON.parse(command("cat #{node_file}").stdout)
#node=node['default'].merge!(node['override'])

describe package('kubernetes-worker-elq') do
  it { should be_installed }
end

%W{ kubelet kube-proxy }.each do |k8s_svc|
  describe systemd_service(k8s_svc) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

#describe port(node['skynet']['etcd']['client_port']) do
=begin
[ 8080, 6443 ].each do |kube_api_port|
  describe port(kube_api_port) do 
    it { should be_listening }
    its('processes') { should include 'kube-apiserver' }
    its('protocols') { should include 'tcp' }
  end
end
=end
