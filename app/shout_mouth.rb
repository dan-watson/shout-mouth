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
require Dir.pwd + '/app/models/tag'
require Dir.pwd + '/app/models/category'
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
    #if not found check legacy routes first
    @code = "<pre class=\"prettyprint\">require_relative 'base/shout_record'\n\nrequire 'akismetor'\n\nclass Comment\n  include Shout::Record\n  \n    property :comment_author, String\n    property :comment_author_email, String\n    property :comment_content, Text\n    property :comment_author_url, String\n    property :user_ip, String\n    property :user_agent, Text\n    property :referrer, String\n    property :is_spam, Boolean\n    \n    validates_presence_of :comment_author, :comment_author_email\n    validates_format_of :email, :as =&gt; :comment_author_email\n  \n    belongs_to :post\n    \n    def spam?       \n        comment_attributes = {\n          :key =&gt; Blog.akismet_key,  #Grab From Config\n          :blog =&gt; Blog.url, #Grab From Config\n          :user_ip =&gt; user_ip,\n          :user_agent =&gt; user_agent, \n          :referrer =&gt; referrer,\n          :permalink =&gt; post.permalink,\n          :comment_type =&gt; 'comment',\n          :comment_author =&gt; comment_author,\n          :comment_author_email =&gt; comment_author_email,\n          :comment_author_url =&gt; comment_author_url,\n          :comment_content =&gt; comment_content\n        }\n        Akismetor.spam?(comment_attributes)\n    end\n   \n    before :save do\n       self.is_spam = spam?\n    end\n    \n    #Scope\n    def self.all_active_and_ham\n        all_active.all(:is_spam =&gt; false)\n    end\nend</pre>"
    params[:slug]
    haml :post
  end
  
  post '/post/:slug/add_comment' do
    
  end
  
  get '/page/:slug' do
    params[:slug]
    #if not found check legacy routes first
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
  
  #----------------------------------------------------------------------------------#
  #-------------Metaweblog/Blogger/WordPress API-------------------------------------#
  #------send: see methods in the metaweblog api module------------------------------#
  #----------------------------------------------------------------------------------#
  # 
  post '/xmlrpc/' do 
    #generate the xml
    xml =  load_xml_from_request(@request.body.read, @request.params) 
    
    #create xmlrpc request call
    call = XMLRPC::Marshal.load_call(xml)
    
    # convert *.getPost to get_post
    method = call[0].gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase
    
    # if the payload is empty raise an error back to the client
    halt 200, {'Content-Type' => 'text/xml'}, raise_xmlrpc_error("no information has been sent") if xml.empty?
    
    # get the autentication details see - metaweblog module method
    authentication_details = authentication_details_lookup(method, call)
    
    #if authentication fails inform the client
    halt 200, {'Content-Type' => 'text/xml'}, raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(authentication_details)
    
    #if everything with the request is fine send the payload onto the method in the metaweblog module
    response.headers['Content-Type'] = 'text/xml;'
    send(method, call)
  end  
  
  private 
  def load_xml_from_request request_body, request_params
      if request_body.empty?
        hash = request_params
        request_body = (hash.keys + hash.values).join
      end
      return request_body
  end
  
  def authenticated?(authentication_details)
    user = User.find_user(authentication_details[:username])
    if user
      user.authenticate(authentication_details[:password])
    else
      false
    end
  end
  
end