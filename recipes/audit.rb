#
# Cookbook Name:: apache2-take
# Recipe:: audit
#
# Copyright 2015, CREATIONLINE, INC.
#

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

port = node[ 'apache2-take' ][ 'port']

if( node[ 'platform' ] == 'ubuntu' &&
    node[ 'platform_version' ].to_f >= 14.04 )
  apache2_site_default = 'default.conf'
else
  apache2_site_default = 'default'
end

control_group "#{cookbook_name}::#{recipe_name}" do
  #
  # install required packages
  #
  %w{ apache2 git-core curl unzip }.each do |s|
    control "package #{s}" do
      it 'should be installed' do
        expect( package( s ) ).to be_installed
      end
    end
  end

  #
  # start apache2
  #
  control "service #{apache2_name}" do
    it "should be enabled" do
      expect( service( apache2_name ) ).to be_enabled
    end

    it "should be running" do
      expect( service( apache2_name ) ).to be_running
    end

    it "should listening #{port}" do
      expect( port( port ) ).to be_listening
    end
  end

  #
  # change port
  #
  ports_conf = '/etc/apache2/ports.conf'
  control "file #{ports_conf}" do
    it "should be a file" do
      expect( file( ports_conf ) ).to be_file
    end
    it "should be owned by root" do
      expect( file( ports_conf ) ).to be_owned_by( 'root' )
    end
    it "should be grouped into root" do
      expect( file( ports_conf ) ).to be_grouped_into( 'root' )
    end
    it "should be mode 644" do
      expect( file( ports_conf ) ).to be_mode( 644 )
    end
    it "should contain 'NameVirtualHost *:#{port}'" do
      expect( file( ports_conf ) ).to contain( "NameVirtualHost *:#{port}" )
    end
    it "should contain 'Listen #{port}'" do
      expect( file( ports_conf ) ).to contain( "Listen #{port}" )
    end
  end

  default_conf = "/etc/apache2/sites-available/#{apache2_site_default}"
  control "file #{default_conf}" do
    it "should be a file" do
      expect( file( default_conf ) ).to be_file
    end
    it "should be owned by root" do
      expect( file( default_conf ) ).to be_owned_by( 'root' )
    end
    it "should be grouped into root" do
      expect( file( default_conf ) ).to be_grouped_into( 'root' )
    end
    it "should be mode 644" do
      expect( file( default_conf ) ).to be_mode( 644 )
    end
    it "should contain '<VirtualHost *:#{port}>'" do
      expect( file( default_conf ) ).to contain( "<VirtualHost *:#{port}>" )
    end
  end

  #
  # enable default site
  #
  control "symlink #{apache2_site_default}" do
    it "should be linked to the available file" do
      if os[ :family ] == 'ubuntu' && os[ :release ].to_f >= 14.04
        expect( file( "/etc/apache2/sites-enabled/#{apache2_site_default}" ) ).to \
          be_linked_to( "../sites-available/#{apache2_site_default}" )
      else
        expect( file( "/etc/apache2/sites-enabled/000-default" ) ).to \
          be_linked_to( "../sites-available/default" )
      end
    end
  end

  #
  # content git file
  #
  index_html = '/var/www/index.html'
  control "file www content" do
    it "should be a file" do
      expect( file( index_html ) ).to be_file
    end
    it "should contain welcome banner" do
      expect( file( index_html ) ).to contain( 'Welcome to my top page' )
    end
  end

  #
  # content static dir
  #
  img_dir = '/var/www/img'
  control "dir www content" do
    it "should be a directory" do
      expect( file( img_dir ) ).to be_directory
    end
  end
end

#
# [EOF]
#
