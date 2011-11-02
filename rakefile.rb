namespace :check do
  desc "Send a get request to all urls ShoutMouth has generated"
  task :all_urls do
    resp = Net::HTTP.get_response(URI.parse(Blog.url))
    puts "status: #{resp.code} - #{Blog.url}"

    resp = Net::HTTP.get_response(URI.parse("#{Blog.url}/archive"))
    puts "status: #{resp.code} - #{Blog.url}/archive"

    resp = Net::HTTP.get_response(URI.parse("#{Blog.url}/sitemap.xml"))
    puts "status: #{resp.code} - #{Blog.url}/sitemap.xml"

    resp = Net::HTTP.get_response(URI.parse("#{Blog.url}/rss.xml"))
    puts "status: #{resp.code} - #{Blog.url}/rss.xml"

    Blog.urls.each do |url|
      resp = Net::HTTP.get_response(URI.parse(url[:page]))
      puts "status: #{resp.code} - #{url[:page]}"
    end
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
  end

  desc "Upgrade The Database"
  task :update do |t, args|
    DataMapper.auto_upgrade!
  end

  desc "Create Or Update The Database"
  task :migrate do |t, args|
    unless File.exists?(File.dirname(__FILE__) + "/db/shout_mouth.db")
      Rake::Task["db:create"].invoke
    else
      DataMapper.auto_migrate! 
    end 
  end

  desc "Delete Database File"
  task :delete do |t, args|
    FileUtils.rm_rf(File.dirname(__FILE__) + "/db/shout_mouth.db")
  end

  desc "Seed Demo Data"
    task :demo_data do |t, args|
      Rake::Task["db:create"].invoke
      TestDataHelper.wipe_database
      TestDataHelper.settings
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
    TestDataHelper.settings  
    exec 'rspec -c ' + File.dirname(__FILE__) + '/tests/*.rb'
  end
end

namespace :user do
  desc "Create a use - create email=email password=password firstname=firstname lastname=lastname"
  task :create do |t, args|
    User.new(:email => args.email, :password => args.password, :firstname => args.firstname, :lastname => args.lastname).save
  end
end
