#
# Cookbook Name:: swift            
# Recipe:: default
#
# Copyright 2010, Cloudscaling
#

include_recipe "apt"

package "ntp"

%w{curl gcc git-core memcached python-configobj python-coverage python-dev python-nose python-setuptools python-simplejson python-xattr sqlite3 xfsprogs xfsprogs xfsdump acl attr}.each do |pkg_name|
  package pkg_name
end

%w{eventlet webob}.each do |python_pkg|
  easy_install_package python_pkg 
end

user "swift" do
  manage_home true
  shell "/bin/bash"
end


file "/etc/sudoers.d/swift" do
    content "vagrant ALL = (swift) NOPASSWD: ALL"
    mode 0440
end

directory "/home/swift" do
  owner "swift"
  group "swift"
end

directory "/var/run/swift" do
  owner "swift"
  group "swift"
  recursive true
  mode 0755
end

directory "/var/cache/swift/" do
  owner "swift"
  group "swift"
  recursive true
end

directory "/etc/swift" do
  owner "swift"
  group "swift"
end

template "/etc/swift/swift.conf" do
  source "swift.conf.erb"
  owner "swift"
  group "swift"
end

directory "/etc/swift/backups" do
  owner "swift"
  group "swift"
end

template "/etc/rsyncd.conf" do
  source "rsyncd.conf.erb"
  variables(
    :servers => {}
  )
end

cookbook_file "/etc/default/rsync" do
  source "default-rsync"
end

cookbook_file "/home/swift/.swiftrc" do
  source "swiftrc"
end

service "rsync" do
  action :start
  supports :restart => true
  subscribes :restart, resources(:template => "/etc/rsyncd.conf")
end

include_recipe "swift::install"
include_recipe "swift::rsyslogd"
include_recipe "swift::demo_device"

["object-server","account-server","container-server"].each do |server|
  next unless node[:swift_servers] && node[:swift_servers][server]

  include_recipe "swift::#{server}"

end

if(node[:rings])
  node[:rings].each do |t,vals|
    vals.each do |s,w|
      add_ring_node t do
        server s
        weight w
      end
    end

    if(!File.exists?("/etc/swift/#{t}.ring.gz"))
      swift_service "#{t}-server" do
        action :rebalance
      end
    end
  end
end

#include_recipe "swift::auth-server"
include_recipe "swift::proxy-server"

template "/etc/init.d/swift-main-services" do
    source "init-script.erb"
    mode 0755
    variables(:server => "main")
end

service "swift-main-services" do
    supports :stop => true, :start => true, :status => true
    action [:start, :enable]
    subscribes :restart, resources(:template => "/etc/swift/proxy-server.conf")
end
