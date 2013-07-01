#
# Cookbook Name:: swift            
# Recipe:: proxy-server
#
# Copyright 2010, Cloudscaling
#

include_recipe "swift::account-server"
include_recipe "swift::ssl-certificates"

template "/etc/swift/proxy-server.conf" do
  source "proxy-server.conf.erb"
  owner "swift"
  group "swift"
  variables(
    :use_ssl => node[:swift][:auth_server][:use_ssl]
  )
end
