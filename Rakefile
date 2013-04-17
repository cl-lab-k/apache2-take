#!/usr/bin/env rake

desc 'chefspec'
task :rspec do |t|
  if Gem::Version.new( '1.9.2' ) <= Gem::Version.new( RUBY_VERSION.dup )
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new( :rspec ) do |t|
      spec_files_path = './spec/*_spec.rb'
      t.pattern = spec_files_path
      t.rspec_opts = ['-c']
    end
  end
end

desc 'foodcritic'
task :foodcritic do |t|
  if Gem::Version.new( '1.9.2' ) <= Gem::Version.new( RUBY_VERSION.dup )
    # "FC008: Generated cookbook metadata needs updating" is for handson
    sh "foodcritic -f ~FC008 #{File.dirname( __FILE__ )}"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

task :default => [ :rspec, :foodcritic ]
