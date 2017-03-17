# Cookbook Name:: example
#
# Resource:: riakcs
#

actions :install, :configure, :create_admin
default_action :install

attribute :riakcs_package_version, :kind_of => String, :default => "2.1.1-1.el7.centos"
attribute :stanchion_package_version, :kind_of => String, :default => "2.1.1-1.el7.centos"
attribute :stanchion_host, :kind_of => String, :default => "127.0.0.1"
attribute :endpoint, :kind_of => String, :default => node.to_hash.dig("s3", "domain") ? node["s3"]["domain"] : "s3.cluster"
attribute :access_key, :kind_of => String, :default => "admin-key"
attribute :secret_key, :kind_of => String, :default => "admin-key"
