#
# Cookbook Name:: swift
# Recipe:: account-server
#
# Copyright 2010, Cloudscaling
#

[:setup, :build, :start].each do |a|

  node[:swift_servers]["account-server"].each do |p,d|
    swift_service "account-server" do
      port p.to_i
      devices d
      action a
    end

    t = resources(:template => "/etc/rsyncd.conf")
    t.variables[:servers]["account-server" + p.to_s] = d

  end
end
