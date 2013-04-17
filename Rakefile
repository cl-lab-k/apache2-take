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

desc 'knife cookbook test'
task :knife do
  Rake::Task[ :prepare_sandbox ].execute
  sh "bundle exec knife cookbook test cookbook -c test/.chef/knife.rb -o #{sandbox_path}/../"
end
task :prepare_sandbox do
  files = %w{*.md *.rb attributes definitions files libraries providers recipes resources templates}

  rm_rf sandbox_path
  mkdir_p sandbox_path
  cp_r Dir.glob("{#{files.join(',')}}"), sandbox_path
end

private
def sandbox_path
  File.join(File.dirname(__FILE__), %w(tmp cookbooks cookbook))
end

task :default => [ :rspec, :knife, :foodcritic ]
