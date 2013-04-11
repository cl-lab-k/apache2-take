require File.expand_path('../support/helpers', __FILE__)

describe 'apache2-take::default' do
  include Helpers::Apache2Take

  %w{ apache2 git-core curl unzip }.each do |s|
    it "installs #{s}" do
      package( s ).must_be_installed
    end
  end

  %w{ /etc/apache2/ports.conf /etc/apache2/sites-available/default }.each do |s|
    it "exists #{s}" do
      file( s ).must_exist
    end
  end

  it 'boots on startup' do
    service( 'apache2' ).must_be_enabled
  end

  it 'creates /var/www/index.html' do
    file( '/var/www/index.html' ).must_exist
  end

  it 'creates /var/www/img' do
    directory( '/var/www/img' ).must_exist
  end

  it 'runs as a daemon' do
    service( 'apache2' ).must_be_running
  end
end
