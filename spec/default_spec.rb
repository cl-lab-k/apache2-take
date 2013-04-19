require 'chefspec'

describe 'apache2-take::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'apache2-take::default' }

  %w{ apache2 git-core curl unzip }.each do |s|
    it "install #{s}" do
      chef_run.should install_package s
    end
  end

  it 'start on boot' do
    chef_run.should set_service_to_start_on_boot 'apache2'
  end

  describe 'change port' do
    %w{ /etc/apache2/ports.conf /etc/apache2/sites-available/default }.each do |s|
      it "create #{s}" do
        chef_run.should create_file_with_content s, chef_run.node[ 'apache2-take' ][ 'port' ]
        chef_run.template( s ).should be_owned_by( 'root', 'root' )
        chef_run.template( s ).mode.should == 00644
        chef_run.template( s ).should notify( 'service[apache2]', :restart )
      end
    end
  end

  describe 'set content' do
    s = 'https://github.com/cl-lab-k/apache2-take-sample-page'
    it "clone #{s}" do
      chef_run.git( s )
    end

    it 'create /var/www/index.html' do
      chef_run.execute( "cp -f #{Chef::Config[ :file_cache_path ]}/apache2-take-sample-page/index.html /var/www/index.html" )
    end
  end

  describe 'setcontent (static)' do
    it 'get apache2-take-sample-image.zip' do
      chef_run.remote_file( "https://github.com/cl-lab-k/apache2-take-sample-image/archive/master.zip" )
    end

    it 'unzip apache2-take-sample-image.zip' do
      chef_run.execute( "unzip -o -d #{Chef::Config[ :file_cache_path ]} #{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image.zip" )
      # not_if { ::File.exists?( "#{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image-master" ) }
    end

    it 'move /var/www/img' do
      chef_run.execute( "mv -f #{Chef::Config[ :file_cache_path ]}/apache2-take-sample-image-master /var/www/img" )
      # not_if { ::File.exists?( '/var/www/img' ) }
    end
  end

  it 'start apache2' do
    chef_run.should start_service 'apache2-start'
  end
end
