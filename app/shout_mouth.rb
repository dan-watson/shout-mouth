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
    @code = "<pre class=\"prettyprint\">\nrequire 'digest/sha1'\nrequire_relative 'base/shout_record'\n\nclass User\n    include Shout::Record\n      \n      property :firstname, String\n      property :lastname, String\n      property :email, String\n      property :password, Object\n      property :salt, Object, :writer =&gt; :private\n  \n      validates_presence_of :firstname, :lastname, :email, :password\n      validates_format_of :email, :as =&gt; :email_address\n    \n      has n, :posts\n \n      def initialize(attributes = nil)\n         super(attributes)\n        \n          if new?\n            self.salt = generate_salt\n            \n            if attributes &amp;&amp; attributes.has_key?(:password)\n              self.password = encrypt_password attributes[:password], self.salt\n            end\n                    \n          end\n      end\n      \n      def self.find_user email\n          User.first(:email =&gt; email, :is_active =&gt; true)\n      end\n      \n      def authenticate password\n        encrypt_password(password, self.salt) == self.password \n      end\n      \n      def fullname\n        &quot;\#{firstname} \#{lastname}&quot;\n      end\n      \n      def to_metaweblog\n          {\n            :userid =&gt; id,\n            :firstname =&gt; firstname,\n            :lastname =&gt; lastname,\n            :url =&gt; Blog.url,\n            :email =&gt; email,\n            :nickname =&gt; fullname\n          }\n      end\n      \n      def to_wordpress_author\n          {\n            :user_id =&gt; id,\n            :user_login =&gt; email,\n            :display_name =&gt; fullname,\n            :user_email =&gt; email,\n            :meta_value =&gt; &quot;&quot;\n          }\n      end\n\n      private\n    \n      def generate_salt\n        (0...8).map{rand(25).chr}.join\n      end\n    \n      def encrypt_password password, salt\n        Digest::SHA1.hexdigest(password + salt)\n      end\nend</pre>"
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