#
# Cookbook Name:: swift            
# Recipe:: container-server
#
# Copyright 2010, Cloudscaling
#

[:setup, :build, :start].each do |a|

  node[:swift_servers]["container-server"].each do |p,d|
    swift_service "container-server" do
      port p.to_i
      devices d
      action a
    end

    t = resources(:template => "/etc/rsyncd.conf")
    t.variables[:servers]["container-server" + p.to_s] = d

  end
end
