#
# Cookbook Name:: swift            
# Recipe:: auth-server
#
# Copyright 2010, Cloudscaling
#

include_recipe "swift::account-server"
include_recipe "swift::ssl-certificates"

template "/etc/swift/auth-server.conf" do
  source "auth-server.conf.erb"
  owner "swift"
  group "swift"
  variables(
    :use_ssl => node[:swift][:auth_server][:use_ssl],
    :hostname => node[:swift][:proxy_server][:hostname]
  )
end
