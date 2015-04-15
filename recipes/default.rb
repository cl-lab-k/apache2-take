#
# Cookbook Name:: apache2-take
# Recipe:: default
#
# Copyright 2013, CREATIONLINE, INC.
#

#
# update apt database
#
execute 'apt-get update'

#
# install required packages
#
%w{ apache2 git-core curl unzip }.each do |s|
  package s
end

#
# set apache2 service_name
#
case node['platform_family']
when "rhel", "fedora", "suse"
  apache2_name = "httpd"
when "debian"
  apache2_name = "apache2"
when "arch"
  apache2_name = "httpd"
when "freebsd"
  apache2_name = "apache22"
end

#
# this is part of opscode-cookbooks/apache2/recipes/default.rb
#
service 'apache2' do
  # If restarted/reloaded too quickly httpd has a habit of failing.
  # This may happen with multiple recipes notifying apache to restart - like
  # during the initial bootstrap.
  case node['platform_family']
  when "rhel", "fedora", "suse"
    restart_command "/sbin/service httpd restart && sleep 1"
    reload_command "/sbin/service httpd reload && sleep 1"
  when "debian"
    restart_command "/usr/sbin/invoke-rc.d apache2 restart && sleep 1"
    reload_command "/usr/sbin/invoke-rc.d apache2 reload && sleep 1"
  end
  service_name apache2_name
  supports [:restart, :reload, :status]
  action :enable
end

#
# change port (ports.conf)
#
template '/etc/apache2/ports.conf' do
  source 'ports.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables( { :port => node[ 'apache2-take' ][ 'port'] } )
  notifies :restart, 'service[apache2]'
end

#
# change port (apache2 site default)
#
if( node[ 'platform' ] == 'ubuntu' &&
    node[ 'platform_version' ].to_f >= 14.04 )
  apache2_site_default = 'default.conf'
else
  apache2_site_default = 'default'
end
template "/etc/apache2/sites-available/#{apache2_site_default}" do
  source 'default.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables( { :port => node[ 'apache2-take' ][ 'port'] } )
  notifies :restart, 'service[apache2]'
end

#
# enable default site
#
execute 'a2ensite default' do
  command 'a2ensite default'
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
service 'apache2-start' do
  service_name apache2_name
  action :start
end

#
# [EOF]
#
