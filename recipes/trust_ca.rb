yum_package 'ca-certificates' do
  action :install
end

execute 'Enable ca-trust' do
  command 'update-ca-trust enable'
end

execute 'Extract ca-trust' do
  command 'update-ca-trust extract'
end
