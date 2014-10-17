require 'serverspec'
begin
  set :backend, :exec
rescue Exception
  require 'pathname'
  ### include requirements ###

  include SpecInfra::Helper::Exec
  include SpecInfra::Helper::DetectOS

  RSpec.configure do |c|
    if ENV['ASK_SUDO_PASSWORD']
      require 'highline/import'
      c.sudo_password = ask("Enter sudo password: ") { |q| q.echo = false }
    else
      c.sudo_password = ENV['SUDO_PASSWORD']
    end
    c.before :all do
      c.os = backend(Serverspec::Commands::Base).check_os
    end
  end
end
