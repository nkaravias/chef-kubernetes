# skynet Cookbook

Deploys a full kubernetes stack (etcd, kubernetes control plane & kubernetes workers)

## Requirements

### Platforms

Centos-based systems (Tests executed on OEL7)

## Attributes

* yum repository namespace: `node['skynet']['yum']`
* etcd related attributes are on the `node['skynet']['etcd']` namespace
* Global kubernetes attribute namespace: `node['skynet']['kubernetes']`
* Docker attribute namespace: `node['skynet']['docker']`
* Kubernetes master namespace: `node['skynet']['kubernetes']['master']`
* Kubernetes API namespace: `node['skynet']['kubernetes']['master']['api']`
* Kubernetes scheduler namespace: `node['skynet']['kubernetes']['master']['scheduler']`
* Kubernetes controller namespace: `node['skynet']['kubernetes']['master']['cmanager']`
* Kubernetes worker namespace: `node['skynet']['kubernetes']['worker']`
* Kubernetes kubelet namespace: `node['skynet']['kubernetes']['worker']['kubelet']`
* Kubernetes kube-proxy namespace: `node['skynet']['kubernetes']['worker']['kube-proxy']`
* Kubernetes worker CNI namespace: `node['skynet']['kubernetes']['worker']['cni']`

Attention required for the following attributes:
* The attribute ['skynet']['kubernetes']['master']['api']['chef-tag'] specifies the tag that identifies a kubernetes api server.
* The kubelet needs to be configuring during it's bootstrap phase to talk to an API endpoint. The attribute  ['skynet']['kubernetes']['worker']['api-endpoints'] is an array that can be used to store potential API endpoings (or a VIP) that the kubelet can use. For example ["https://server1:443","https://server2"]. If this attribute is not set, chef will do the following:
* node search for "tags:node['skynet']['kubernetes']['master']['api']['chef-tag'] AND chef_environment:node.environment"
* Inject the rendered server endpoints into the kubelet bootstrap and kube-proxy kubeconfig templates

Details are found on:
* attributes/etcd.rb
* attributes/kubernetes.rb
* attributes/default.rb

***

## Data bags
A data bag containing certificate information is required. The location and name are stored on the following attributes:
* ['skynet']['kubernetes']['master']['certificate_data_bag_info']
* ['skynet']['kubernetes']['master']['certificate_data_bag_info']
* ['skynet']['kubernetes']['master']['certificate_data_bag_info']

The data bag needs should contain the following keys with the value being the certificate data transformed in Base64:
* kube.server.cert = server certificate for the api & etcd
* kube.server.key
* kube.proxy.client.cert = client certificate for the kube-proxy
* kube.proxy.client.key
* ca.cert
* ca.key

## Usage

### skynet::etcd
### skynet::kubernetes_master
### skynet::kubernetes_worker
### skynet::trust_ca

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the test-kitchen tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: nikolas.karavias@oracle.com

