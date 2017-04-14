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

Details are found on:
* attributes/etcd.rb
* attributes/kubernetes.rb
* attributes/default.rb

***

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

