# Cookbook Name:: example
#
# Resource:: config
#

actions :install, :configure
default_action :install

attribute :stanchion_package_version, :kind_of => String, :default => "2.1.1-1.el7.centos"
