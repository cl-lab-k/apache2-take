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
%w{ apache2 git curl unzip }.each do |s|
  package s
end

#
# start apache2
#
service 'apache2' do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
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
# [EOF]
#
