# Cookbook Name:: s3riak
#
# Provider:: config
#

action :install do

  stanchion_package_version = new_resource.stanchion_package_version

  packagecloud_repo "basho/stanchion" do
    type "rpm"
  end

  package "stanchion" do
    action :install
    version stanchion_package_version
  end

  template "/usr/lib/systemd/system/stanchion.service" do
    source    "stanchion.service.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    notifies :run, 'bash[systemd-reload]', :immediate
  end

end

action :configure do

  template "/etc/stanchion/stanchion.conf" do
    source    "stanchion.conf.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    variables( lazy {
      keys = Chef::DataBagItem.load("s3", "admin") rescue keys = {}
      if keys.empty?
        keys = {  "key_id" => "admin-key" ,
                  "key_secret" => "admin-key"
        }
      end
      {
        :access_key => keys["key_id"],
        :secret_key => keys["key_secret"]
      } } )
    notifies :restart, 'service[stanchion]', :immediate
  end

  service "stanchion" do
    supports :status => true, :start => true, :restart => true
    action [:enable, :start]
  end

end
