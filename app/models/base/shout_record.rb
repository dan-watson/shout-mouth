require 'dm-core'
require 'dm-validations'
require 'dm-types'

module Shout
  module Record
    #DataMapper::Logger.new(STDOUT, :debug)
    DataMapper.setup(:default, "sqlite:///#{File.dirname(__FILE__)}/../../../db/shout_mouth.db")
    
    def self.included(base)
      base.class_eval do
        include DataMapper::Resource
        property :id, DataMapper::Property::Serial
        property :is_active, DataMapper::Property::Boolean, :default => true
        property :created_at, DataMapper::Property::DateTime, :default => lambda{ |p,s| DateTime.now}

        #Scope
        def self.all_active
          all(:is_active => true, :order => [ :created_at.desc ])
        end

        #Help
        def created_at_iso8601
          created_at.strftime("%Y%m%dT%H:%M:%S")
        end
      end
    end
  end
end