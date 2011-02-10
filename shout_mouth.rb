require 'rubygems'
require 'sinatra'
require Dir.pwd + '/models/base/shout_record'
require Dir.pwd + '/models/user'
require Dir.pwd + '/models/post'
require Dir.pwd + '/models/comment'
require Dir.pwd + '/models/legacy_route'
require Dir.pwd + '/models/blog'

class ShoutMouth < Sinatra::Base
    
  get '/' do
    "Hello world, it's #{Time.now} at the server!"
  end
  
  get '/post/:slug' do
    params[:slug]
  end
  
  get '/page/:slug' do
    params[:slug]
  end
  
  get '/archive' do
  
  end
      
  # Catches all routes - Will first check the legacy routes to see if 
  # a redirect is needed else it will render a 404 
  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    redirect "/post/#{legacy_route.post.slug}", 301 unless legacy_route.nil?
    redirect '/', 404
  end

end