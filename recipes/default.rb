#
# Cookbook Name:: apache2-take
# Recipe:: default
#
# Copyright 2013, CREATIONLINE, INC.
#

#
# install required packages
#
execute 'apt-get update'
%w{ apache2 git-core curl unzip }.each do |s|
  package s
end

#
# this is part of opscode-cookbooks/apache2/recipes/default.rb
#
service 'apache2' do
  case node['platform_family']
  when "rhel", "fedora", "suse"
    service_name "httpd"
    # If restarted/reloaded too quickly httpd has a habit of failing.
    # This may happen with multiple recipes notifying apache to restart - like
    # during the initial bootstrap.
    restart_command "/sbin/service httpd restart && sleep 1"
    reload_command "/sbin/service httpd reload && sleep 1"
  when "debian"
    service_name "apache2"
    restart_command "/usr/sbin/invoke-rc.d apache2 restart && sleep 1"
    reload_command "/usr/sbin/invoke-rc.d apache2 reload && sleep 1"
  when "arch"
    service_name "httpd"
  when "freebsd"
    service_name "apache22"
  end
  supports [:restart, :reload, :status]
  action :enable
end

#
# change port
#
template '/etc/apache2/ports.conf' do
  source 'ports.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables( { :port => node[ 'apache2-take' ][ 'port'] } )
  notifies :restart, 'service[apache2]'
end
template '/etc/apache2/sites-available/default' do
  source 'default.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables( { :port => node[ 'apache2-take' ][ 'port'] } )
  notifies :restart, 'service[apache2]'
end

#
# set content (git)
#
git "#{Chef::Config[ :file_cache_path ]}/apache2-take-sample-page" do
  repository 'https://github.com/cl-lab-k/apache2-take-sample-page'
end
execute '/var/www/index.html' do
  command "cp -f #{Chef::Config[ :file_cache_path ]}/apache2-take-sample-page/index.html /var/www/index.html"
end

#
# set content (static)
#
remote_file "#{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image.zip" do
  source 'https://github.com/cl-lab-k/apache2-take-sample-image/archive/master.zip'
end
execute 'unzip apache2-take-sample-image.zip' do
  command "unzip -o -d #{Chef::Config[ :file_cache_path ]} #{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image.zip"
  not_if { ::File.exists?( "#{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image-master" ) }
end
execute '/var/www/img' do
  command "mv -f #{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image-master /var/www/img"
  not_if { ::File.exists?( '/var/www/img' ) }
end

#
# start apache2
#
service 'apache2' do
  action :start
end

#
# [EOF]
#
