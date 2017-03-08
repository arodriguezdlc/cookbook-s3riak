#
# Cookbook Name:: example
# Recipe:: default
#

s3riak_riakcs "configure riakcs" do
  action [:configure, :create_admin]
end
