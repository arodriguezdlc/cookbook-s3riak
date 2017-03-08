#
# Cookbook Name:: example
# Recipe:: default
#

s3riak_stanchion "stanchion" do
  action [:install,:configure]
end
