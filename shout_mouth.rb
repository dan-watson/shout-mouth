require 'rubygems'
require 'sinatra'

class ShoutMouth < Sinatra::Base
  
  get '/' do
    "Hello world, it's #{Time.now} at the server!"
  end

end