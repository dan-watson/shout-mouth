namespace :db do
    require 'fileutils'
    require 'dm-core'
    require 'dm-migrations'
    require File.dirname(__FILE__) + '/app/shout_mouth.rb'
        
    desc "Create The Database"
    task :create do |t, args|
        DataMapper.auto_migrate!
    end
    
    desc "Upgrade The Database"
    task :update do |t, args|
      DataMapper.auto_upgrade!
    end
    
    desc "Delete Database File"
    task :delete do |t, args|
      FileUtils.rm_rf(File.dirname(__FILE__) + "/db/shout_mouth.db")
    end 
end

namespace :specs do
  ENV['RACK_ENV'] = 'test'

  desc "Run All The Specs"
  task :run_all do |t, args|
    Rake::Task["db:create"].invoke    
    exec 'rspec -c ' + File.dirname(__FILE__) + '/tests/*.rb'
  end
end

