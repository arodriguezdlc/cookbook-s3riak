# Cookbook Name:: example
#
# Resource:: riak
#

actions :install, :configure, :join
default_action :install

attribute :riakcs_version, :kind_of => String, :default => "2.1.1"
attribute :riak_package_version,   :kind_of => String, :default => "2.2.0-1.el7.centos"
