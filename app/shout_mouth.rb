require 'rubygems'
require 'sinatra'
require 'haml'
require 'xmlrpc/marshal'
require 'aws/s3'
require Dir.pwd + '/app/models/base/shout_record'
require Dir.pwd + '/app/models/user'
require Dir.pwd + '/app/models/post'
require Dir.pwd + '/app/models/comment'
require Dir.pwd + '/app/models/legacy_route'
require Dir.pwd + '/app/models/blog'
require Dir.pwd + '/app/api/metaweblog'

class ShoutMouth < Sinatra::Base
    include Metaweblog
    
  set :public, File.dirname(__FILE__) + '/../public'
  set :views, File.dirname(__FILE__) + '/views'
  
  get '/' do
    #"Hello world, it's #{Time.now} at the server!"
    haml :index
  end
  
  get '/post/:year/:month/:day/:slug' do
    params[:slug]
    haml :post
  end
  
  post '/post/:slug/add_comment' do
    
  end
  
  get '/page/:slug' do
    params[:slug]
  end
  
  get '/category/:category' do
    params[:category]
  end
  
  get '/tag/:tag' do
    params[:tag]
  end 
  
  get '/archive' do
    haml :archive
  end
  
  get '/rss' do
    
  end
  
  get '/rsd.xml' do
    content_type 'text/xml'
    erb :rsd
  end
  
  get '/webpreview.html' do
      haml :preview
  end
  
  # Catches all routes - Will first check the legacy routes to see if 
  # a redirect is needed else it will render a 404 
  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    redirect "/post/#{legacy_route.post.slug}", 301 unless legacy_route.nil?
    redirect '/', 404
  end
  
  #---------------------------------------------------------#
  #-------------Metaweblog/Blogger/WordPress API------------#
  #------send: see methods in the metaweblog api module-----#
  #---------------------------------------------------------#
  post '/xmlrpc/' do 
    xml = @request.body.read
    if xml.empty?
      hash = @request.params
      xml = (hash.keys + hash.values).join
    end
    
    return raise_xmlrpc_error("no information has been sent") if xml.empty?

    call = XMLRPC::Marshal.load_call(xml)
    
    # convert *.getPost to get_post
    method = call[0].gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase
    response.headers['Content-Type'] = 'text/xml;'
    send(method, call)
  end  
end