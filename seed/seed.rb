# require 'rubygems'
# require 'dm-core'
# require 'dm-validations'
# require Dir.pwd + '../../models/base'
# require Dir.pwd + '../../models/comment'
# require Dir.pwd + '../../models/post'
# require Dir.pwd + '../../models/user'
# 
# property :id, Serial
# property :email, String
# property :password, String
# property :salt, String
# property :is_active, Boolean
# property :created_at, DateTime
# Post.new(:email => "dan@dotnetguy.co.uk", :password => "pwd", )
