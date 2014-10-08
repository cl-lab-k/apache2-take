require 'chefspec'

describe 'apache2-take::default' do
  let (:chef_run) { ChefSpec::Runner.new.converge 'apache2-take::default' }

  %w{ apache2 git-core curl unzip }.each do |s|
    it "install #{s}" do
      expect( chef_run ).to install_package( s )
    end
  end

  it 'start on boot' do
    expect( chef_run ).to enable_service( 'apache2' )
  end

  describe 'change port' do
    %w{ /etc/apache2/ports.conf /etc/apache2/sites-available/default }.each do |s|
      it "create #{s}" do
        expect( chef_run ).to render_file( s ).with_content( chef_run.node[ 'apache2-take' ][ 'port' ] )
        expect( chef_run ).to create_template( s )
        file = chef_run.template( s )
        expect( file.owner ).to eq( 'root' )
        expect( file.group ).to eq( 'root' )
        expect( file.mode ).to eq( 00644 )
        expect( file ).to notify( 'service[apache2]' ).to( :restart )
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
    expect( chef_run ).to start_service 'apache2-start'
  end
end
