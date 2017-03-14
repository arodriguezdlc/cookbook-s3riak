# Cookbook Name:: s3riak
#
# Provider:: riakcs
#


action :install do #Usually used to install and configure something

  riakcs_package_version = new_resource.riakcs_package_version

  packagecloud_repo "basho/riak-cs" do
    type "rpm"
  end

  package "riak-cs" do
    action :install
    version riakcs_package_version
  end

  template "/usr/lib/systemd/system/riak-cs.service" do
    source    "riak-cs.service.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    notifies :run, 'bash[systemd-reload]', :immediate
  end

end

action :configure do

  stanchion_host = new_resource.stanchion_host
  endpoint = new_resource.endpoint


  template "/etc/riak-cs/advanced.config" do
    source    "advanced-cs.config.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    variables(:endpoint => endpoint)
  end

  template "/etc/riak-cs/riak-cs.conf" do
    source    "riak-cs.conf.erb"
    owner     "root"
    group     "root"
    cookbook  "s3riak"
    mode      0644
    retries   2
    variables(
            lazy {
              anonymous_status = "off"
              keys = Chef::DataBagItem.load("s3", "admin") rescue keys = {}
              stanchion = Chef::DataBagItem.load("s3", "stanchion") rescue stanchion = {}
              if keys.empty?
                keys = {  "key_id" => "admin-key" ,
                          "key_secret" => "admin-key"
                }
                anonymous_status = "on"
              end
              if stanchion.empty?
                stanchion = { "ipaddress" => "127.0.0.1" }
              end
              {
                :stanchion_host => stanchion["ipaddress"],
                :anonymous_status => anonymous_status,
                :access_key => keys["key_id"],
                :secret_key => keys["key_secret"]
            } } )
    notifies :restart, 'service[riak-cs]', :immediate
  end

  service "riak-cs" do
    supports :status => true, :start => true, :restart => true, :reload => true
    action [:enable, :start]
  end

end

action :create_admin do

  endpoint = new_resource.endpoint

  s3_keys = Chef::DataBagItem.load("s3", "admin") rescue s3_keys = {}
  if s3_keys.empty?

    ruby_block 'create_admin' do
      block do
        extend Riak::Helpers
        admin = create_admin(endpoint)
        admin["riak-id"] = admin["id"]
        admin["id"] = "admin"
        item = Chef::DataBagItem.from_hash(admin)
        item.data_bag('s3')
        item.save
      end
      action :run
      notifies :create, 'template[/etc/riak-cs/riak-cs.conf]', :immediate
    end

  end

end
