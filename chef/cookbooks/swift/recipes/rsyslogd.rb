#
# Cookbook Name:: swift            
# Recipe:: syslog 
#
# Copyright 2013, SwiftStack
#

directory "/var/log/swift" do
    owner "syslog"
    group "syslog"
end

template "/etc/rsyslog.d/10-swift.conf" do
  source "rsyslogd.conf.erb"
  owner "syslog"
  group "syslog"
end

service "rsyslog" do
  action [:start, :enable]
  subscribes :restart, resources(:template => "/etc/rsyslog.d/10-swift.conf")
end
