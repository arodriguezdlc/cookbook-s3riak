#
# Cookbook Name:: example
# Recipe:: default
#

s3riak_riak "install riak" do
  action :install
end

s3riak_riakcs "install riakcs" do
  action :install
end

s3riak_riak "configure riak" do
  action [:configure, :join]
end
