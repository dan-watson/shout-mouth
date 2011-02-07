require 'dm-core'
require 'dm-validations'

module Base
  DataMapper.setup(:default, "sqlite:///#{File.dirname(__FILE__)}/../db/shout_mouth.db")
  DataMapper::Logger.new(STDOUT, :debug)
  
  def self.included(base)
    base.class_eval do
      include DataMapper::Resource
      property :id, DataMapper::Property::Serial
      property :is_active, DataMapper::Property::Boolean, :writer => :protected, :default => true
      property :created_at, DataMapper::Property::DateTime, :writer => :protected, :default => lambda{ |p,s| DateTime.now}
    end
  end
  
end
