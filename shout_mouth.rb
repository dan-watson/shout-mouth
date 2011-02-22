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
  #-------------Metaweblog/Blogger/WordPress API------------#
  #---------------------------------------------------------#
  post '/xmlrpc/' do
    xml = @request.body.read
    if xml.empty?
      hash = @request.params
      xml = (hash.keys + hash.values).join
    end
    
    return raise_xmlrpc_error("no information has been sent") if xml.empty?

    call = XMLRPC::Marshal.load_call(xml)
    puts xml
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
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    post = Post.new(:title => xmlrpc_call[1][3]["title"], 
                    :body => xmlrpc_call[1][3]["description"], 
                    :tags => "tag1, tag2", #needs to be pulled in from client
                    :categories => xmlrpc_call[1][3]["categories"].join(","), 
                    :user => find_current_user(xmlrpc_call))
                    
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.valid?
    
    post.save
    post.reload

    XMLRPC::Marshal.dump_response(post.id)
  end

  def edit_post(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
   
    post = Post.all(:id => xmlrpc_call[1][0]).first
    post.title = xmlrpc_call[1][3]["title"]
    post.body = xmlrpc_call[1][3]["description"]
    post.categories = xmlrpc_call[1][3]["categories"].join(",")
    post.is_active = xmlrpc_call[1][4]
    post.created_at = xmlrpc_call[1][3]["dateCreated"].to_time  unless xmlrpc_call[1][3]["dateCreated"].nil?
    
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.valid?
    
    post.save
    post.reload

    XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end
  
  def get_post(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
     post = Post.all_active.all(:id => xmlrpc_call[1][0]).first
     XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end
  
  def get_categories(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    categories = []
    posts = Post.all_active.all.each{|post| categories << post.categories}
    XMLRPC::Marshal.dump_response(categories.flatten.uniq.map{|c| {:description => c, :title => c}}) 
  end

  def get_recent_posts(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    posts = Post.all_active.all(:limit => xmlrpc_call[1][3], :order => [:created_at.desc])
    XMLRPC::Marshal.dump_response(posts.map{|p| p.to_metaweblog})
  end
  
  def delete_post(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
     
     post = Post.get(xmlrpc_call[1][1])
     post.is_active = false
     post.save
     
     XMLRPC::Marshal.dump_response(true)
  end

  def get_users_blogs(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    XMLRPC::Marshal.dump_response(Blog.to_metaweblog)
   end
  
  def get_user_info(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    user = find_current_user(xmlrpc_call)
    XMLRPC::Marshal.dump_response(user.to_metaweblog)
  end
  
  #Wordpress API
  def get_pages(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def get_page(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def edit_page(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def delete_page(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def get_authors(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end
  
  def get_tags(xmlrpc_call)
    raise_xmlrpc_error("Not Implemented")
  end

  def authenticated?(email, password)
    user = find_current_user(email)
    if user
      user.authenticate(password)
    else
      false
    end
  end
  
  def find_current_user(email)
      User.find(:email => email).first
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