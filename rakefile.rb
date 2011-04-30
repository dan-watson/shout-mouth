namespace :cache do
  desc "Clear all files from the cache"
  task :clear do |t, args|
    Dir[File.join(File.dirname(__FILE__), "public/cache/**/*")].each{|entry| FileUtils.rm_rf(entry)}
  end
end

namespace :db do
  require 'yaml'
  require 'fileutils'
  require 'dm-core'
  require 'dm-migrations'
  require File.dirname(__FILE__) + '/app/shout_mouth.rb'
  require File.dirname(__FILE__) + '/tests/test_data/test_data_helper'

  desc "Create The Database"
  task :create do |t, args|
    DataMapper.auto_migrate!
    Rake::Task["db:sqlite_file_permissions"].invoke
    Rake::Task["db:seed_settings_from_configuration_file"].invoke
  end

  desc "Upgrade The Database"
  task :update do |t, args|
    DataMapper.auto_upgrade!
  end

  desc "Delete Database File"
  task :delete do |t, args|
    FileUtils.rm_rf(File.dirname(__FILE__) + "/db/shout_mouth.db")
  end

  desc "Seed Data Into Settings Table From config/config.yaml - used to set defaults on initial setup"
  task :seed_settings_from_configuration_file do |t, args|
    
    configuration_directory = File.expand_path("../config/", __FILE__)
    configuration_file = File.exist?("#{configuration_directory}/_config.yaml") ? "#{configuration_directory}/_config.yaml" : "#{configuration_directory}/config.yaml"
    settings = YAML.load_file(configuration_file)["#{ENV['RACK_ENV'].to_s}"]
    settings.each{|setting|
      Blog.send("#{setting[0]}=", setting[1])
    }
  end
  
  desc "Seed Demo Data"
    task :demo_data do |t, args|
      Rake::Task["db:create"].invoke
      TestDataHelper.wipe_database
      TestDataHelper.valid_post
      TestDataHelper.valid_post1
      TestDataHelper.valid_post2
      TestDataHelper.valid_comment
      TestDataHelper.legacy_route
    end

  desc "Set permissions for sqlite database and folder"
    task :sqlite_file_permissions do |t, args|
      #Ok this is stupid
      File.chmod(0777, File.dirname(__FILE__) + "/db/shout_mouth.db")
      File.chmod(0777, File.dirname(__FILE__) + "/db")
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

namespace :user do
  desc "Create a use - create email=email password=password firstname=firstname lastname=lastname"
  task :create do |t, args|
    User.new(:email => args.email, :password => args.password, :firstname => args.firstname, :lastname => args.lastname).save
  end
end
