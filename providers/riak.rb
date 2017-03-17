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

  template "/etc/selinux/config" do
    source    "selinux-config.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    notifies :run, 'bash[setenforce]', :immediate
  end

  bash 'systemd-reload' do
    action :nothing
    code "systemctl daemon-reload"
  end

  bash 'setenforce' do
    action :nothing
    code "setenforce permissive"
  end

end

action :configure do

  riakcs_version = new_resource.riakcs_version
  riak_pass = new_resource.riak_pass

  template "/etc/riak/riak.conf" do
    source    "riak.conf.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    variables(:riak_pass => riak_pass)
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

  chef_data_bag 's3' do
    name "s3"
    action :create
  end

end

action :join do

  ruby_block "riak cluster join" do
    block do
      riak_nodes = search(:node, 'role:riak')
      riak_nodes.delete(node)
      result = false
      if !riak_nodes.empty?
        puts ""
        result = system("riak-admin cluster join riak@#{riak_nodes.sample["ipaddress"]}")
      end
      if result
        system("riak-admin cluster plan && riak-admin cluster commit")
      end
    end
    action :run
  end

end
