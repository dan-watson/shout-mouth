require 'rubygems'
require 'sinatra'
require Dir.pwd + '/models/base'
require Dir.pwd + '/models/user'
require Dir.pwd + '/models/post'
require Dir.pwd + '/models/comment'

class ShoutMouth < Sinatra::Base
  
  get '/' do
    "Hello world, it's #{Time.now} at the server!"
  end

end