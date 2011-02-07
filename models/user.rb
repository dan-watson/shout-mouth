require 'digest/sha1'
require_relative 'base'

class User < Base
    include DataMapper::Resource
    
    property :id, Serial
    property :email, String
    property :password, Object
    property :is_active, Boolean
    property :salt, Object, :writer => :private
    property :created_at, DateTime, :writer => :private

        
    validates_presence_of :email, :password
    validates_format_of :email, :as => :email_address
    
    has n, :posts
 
    def initialize(attributes = nil)
       super(attributes)
        
        if new?
          
          self.is_active = true
          self.created_at = DateTime.now
          self.salt = generate_salt
          
          plain_password =  attributes[:password] if attributes

          if plain_password 
            self.password = encrypt_password plain_password, self.salt
          end
                    
        end
    end
      
    def authenticate password
      encrypt_password(password, self.salt) == self.password 
    end
    
    private
    
    def generate_salt
      (0...8).map{rand(25).chr}.join
    end
    
    def encrypt_password password, salt
      Digest::SHA1.hexdigest(password + salt)
    end
end