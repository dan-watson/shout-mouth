namespace :db do
    require 'dm-core'
    require 'dm-migrations'
    require File.dirname(__FILE__) + '/models/models.rb'
    
    desc "Create The Database"
    task :create do |t, args|
        DataMapper.auto_migrate!
    end
    
    desc "Upgrade The Database"
    task :update do |t, args|
      DataMapper.auto_upgrade!
    end
    
end

