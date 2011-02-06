require 'dm-core'
require 'dm-validations'

class Base
    DataMapper.setup(:default, "sqlite:///#{File.dirname(__FILE__)}/../db/shout_mouth.db")
    DataMapper::Logger.new(STDOUT, :debug)
    
    def initialize(args)
    end

end





