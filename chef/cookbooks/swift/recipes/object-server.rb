#
# Cookbook Name:: swift            
# Recipe:: object-server
#
# Copyright 2010, Cloudscaling
#

[:setup, :build, :start].each do |a|

  node[:swift_servers]["object-server"].each do |p,d|
    swift_service "object-server" do
      port p.to_i
      devices d
      action a
    end

    t = resources(:template => "/etc/rsyncd.conf")
    t.variables[:servers]["object-server" + p.to_s] = d

  end

end
