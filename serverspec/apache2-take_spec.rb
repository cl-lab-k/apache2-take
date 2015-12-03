require 'spec_helper'

%w{ apache2 git-core curl unzip }.each do |i|
  describe package( i ) do
    it { should be_installed }
  end
end

describe service( 'apache2' ) do
  it { should be_enabled }
  it { should be_running }
end

describe port( 8080 ) do
  it { should be_listening }
end

describe file( '/etc/apache2/ports.conf' ) do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
end

if os[ :family ] == 'ubuntu' && os[ :release ].to_f >= 14.04
  apache2_site_default = 'default.conf'
else
  apache2_site_default = 'default'
end

describe file( "/etc/apache2/sites-available/#{apache2_site_default}" ) do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
end

describe file( '/etc/apache2/ports.conf' ) do
  it { should contain 'NameVirtualHost *:8080' }
  it { should contain 'Listen 8080' }
end

describe file( "/etc/apache2/sites-available/#{apache2_site_default}" ) do
  it { should contain '<VirtualHost *:8080>' }
end

if os[ :family ] == 'ubuntu' && os[ :release ].to_f >= 14.04
  describe file( "/etc/apache2/sites-enabled/#{apache2_site_default}" ) do
    it { should be_linked_to "../sites-available/#{apache2_site_default}" }
  end
else
  describe file( "/etc/apache2/sites-enabled/000-default" ) do
    it { should be_linked_to "../sites-available/default" }
  end
end

describe file( '/var/www/index.html' ) do
  it { should be_file }
  it { should contain 'Welcome to my top page' }
end

describe file( '/var/www/img' ) do
  it { should be_directory }
end
