# Cookbook Name:: s3riak
#
# Provider:: riak
#

action :install do #Usually used to install and configure something

  riak_package_version = new_resource.riak_package_version

  # Installs basho repo for riak and riak-cs
  packagecloud_repo "basho/riak" do
    type "rpm"
  end

  package "riak" do
    action :install
    version riak_package_version
  end

  template "/usr/lib/systemd/system/riak.service" do
    source    "riak.service.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    notifies :run, 'bash[systemd-reload]', :immediate
  end

  bash 'systemd-reload' do
    action :nothing
    code "systemctl daemon-reload"
  end

end

action :configure do

  riakcs_version = new_resource.riakcs_version

  template "/etc/riak/riak.conf" do
    source    "riak.conf.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    notifies :restart, 'service[riak]', :immediate
  end

  template "/etc/riak/advanced.config" do
    source    "advanced.config.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    variables(:riakcs_version => riakcs_version)
    notifies :restart, 'service[riak]', :immediate
  end

  service "riak" do
    supports :status => true, :start => true, :restart => true
    action [:enable, :start]
  end

end
