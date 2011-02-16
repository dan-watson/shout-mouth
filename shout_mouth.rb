require 'rubygems'
require 'sinatra'
require 'haml'
require 'xmlrpc/marshal'
require Dir.pwd + '/models/base/shout_record'
require Dir.pwd + '/models/user'
require Dir.pwd + '/models/post'
require Dir.pwd + '/models/comment'
require Dir.pwd + '/models/legacy_route'
require Dir.pwd + '/models/blog'

class ShoutMouth < Sinatra::Base
  
  set :public, File.dirname(__FILE__) + '/public'
  
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
    
  #Metaweblog API
  post '/metaweblog' do
    xml = @request.body.read
    if xml.empty?
      hash = @request.params
      xml = (hash.keys + hash.values).join
    end
    
    raise "Nothing supplied" if xml.empty?

    call = XMLRPC::Marshal.load_call(xml)
    
    # convert metaWeblog.getPost to get_post
    method = call[0].gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase
    response.headers['Content-Type'] = 'text/xml;'
    send(method, call)
  end
  
  # Catches all routes - Will first check the legacy routes to see if 
  # a redirect is needed else it will render a 404 
  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    redirect "/post/#{legacy_route.post.slug}", 301 unless legacy_route.nil?
    redirect '/', 404
  end
  
  
  private
  def new_post(xmlrpc_call)
    raise "Not Implemented"
  end

  def edit_post(xmlrpc_call)
    raise "Not Implemented"
  end
  
  def get_post(xmlrpc_call)
    raise "Not Implemented"
  end
  
  def get_categories(xmlrpc_call)
    raise "Not Implemented"
  end

  def get_recent_posts(xmlrpc_call)
    raise "Not Implemented"
  end
  
  def delete_post(xmlrpc_call)
    raise "Not Implemented"
  end

  def get_users_blogs(xmlrpc_call)
    raise "Not Implemented"
  end
  
  def get_user_info(xmlrpc_call)
    
    data = xmlrpc_call[1]
      # blog_id = data[0]; user = data[1]; pass = data[2]
    user = data[1]
    password = data[2]
    resp = {
          :user => user,
          :password => password,
          :dateCreated => DateTime.now,
          :userid => 1,
          :postid => 1,
          :description => "description",
          :title => "title",
          :link => "full_permalink",
          :permaLink => "#full_permalink",
          :categories => ["General"],
          :date_created_gmt => DateTime.now,
        }
    XMLRPC::Marshal.dump_response(resp)
  end
  
  def authenticate(xmlrpc_call)
    user = User.find(:email => xmlrpc_call[1][1])
    if user.exists?
      user.authenticate(xmlrpc_call[1][2])
    else
      false
    end
  end
  
end