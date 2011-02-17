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
  
  # Catches all routes - Will first check the legacy routes to see if 
  # a redirect is needed else it will render a 404 
  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    redirect "/post/#{legacy_route.post.slug}", 301 unless legacy_route.nil?
    redirect '/', 404
  end
  
  #---------------------------------------------------------#
  #--------------------Metaweblog API-----------------------#
  #---------------------------------------------------------#
  post '/metaweblog' do
    xml = @request.body.read
    if xml.empty?
      hash = @request.params
      xml = (hash.keys + hash.values).join
    end
    
    return raise_xmlrpc_error("no information has been sent") if xml.empty?

    call = XMLRPC::Marshal.load_call(xml)
    
    # convert metaWeblog.getPost or blogger.getPost to get_post
    method = call[0].gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase
    response.headers['Content-Type'] = 'text/xml;'
    send(method, call)
  end

  private
  def new_media_object(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def new_post(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end

  def edit_post(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def get_post(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call)
     post = Post.all_active.all(:id => xmlrpc_call[1][0]).first
     XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end
  
  def get_categories(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call)
    categories = []
    posts = Post.all_active.all.each{|post| categories << post.categories}
    XMLRPC::Marshal.dump_response(categories.flatten.uniq.map{|c| {:description => c, :title => c}}) 
  end

  def get_recent_posts(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call)
    posts = Post.all_active.all(:limit => xmlrpc_call[1][3], :order => [:created_at.desc])
    XMLRPC::Marshal.dump_response(posts.map{|p| p.to_metaweblog})
  end
  
  def delete_post(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end

  def get_users_blogs(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Blog.to_metaweblog)
  end
  
  def get_user_info(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call)
    user = find_current_user(xmlrpc_call)
    XMLRPC::Marshal.dump_response(user.to_metaweblog)
 end
  
  def authenticated?(xmlrpc_call)
    user = find_current_user(xmlrpc_call)
    if user
      user.authenticate(xmlrpc_call[1][2])
    else
      false
    end
  end
  
  def find_current_user(xmlrpc_call)
      User.find(:email => xmlrpc_call[1][1]).first
  end
  
  def raise_xmlrpc_error(message)  
    "<methodResponse>
      <fault>
        <value>
          <struct>
            <member>
              <name>faultCode</name>
              <value><int>40003</int></value>
            </member>
            <member>
              <name>faultString</name>
              <value><string>#{message}</string></value>
          </member>
        </struct>
      </value>
    </fault>
    </methodResponse>"
  end

end
