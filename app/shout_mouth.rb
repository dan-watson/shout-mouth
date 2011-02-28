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
require Dir.pwd + '/app/lib/fixnum'

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
    @article = Post.all_active_pages.all(:persisted_slug => params[:slug]).first

    if @article.nil?
      @article = LegacyRoute.all(:slug => params[:slug]).first.post
      redirect "/page/#{@article.persisted_slug}", 301 unless @article.nil?
    end
    
    if(@article.nil?)
       redirect '/404'
    end
          
    haml :page
    
  end
  
  get '/category/:category' do
    @posts = Category.posts_for_category(params[:category])
    haml :archive
  end
  
  get '/tag/:tag' do
    @posts = Tag.posts_for_tag(params[:tag])
    haml :archive 
  end 
  
  get '/archive' do
    @posts = Post.all_active_posts
    haml :archive
  end
  
  get '/rss' do
    content_type 'text/xml'
    @posts = Post.all_active_posts
    builder :rss, :layout => false
  end
  
  get '/sitemap.xml' do
    content_type 'text/xml'
    @articles = Post.all_active
    builder :sitemap, :layout => false
  end
  
  get '/rsd.xml' do
    content_type 'text/xml'
    builder :rsd, :layout => false
  end
  
  get '/webpreview.html' do
      haml :preview
  end
  
  get %r{/xmlrpc([*.[a-z]/]+)} do 
      "XML-RPC server accepts POST requests only."
  end
  
  # Catch All 
  get '/404' do
    haml :not_found
  end
  
  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    
    if(!legacy_route.nil?)
      if(legacy_route.post.is_page?)
        redirect "/page/#{legacy_route.post.slug}", 301
      else
        redirect "/post/#{legacy_route.post.slug}", 301
      end
    end
    redirect '/404'
  end
  
  
  #----------------------------------------------------------------------------------#
  #-------------Metaweblog/Blogger/WordPress API-------------------------------------#
  #------send: see methods in the metaweblog api module------------------------------#
  #----------------------------------------------------------------------------------#
  # MATCHES - /xmlrpc/ - /xmlrpc.{anything}
  
  post %r{/xmlrpc([*.[a-z]/]+)} do 
    #generate the xml
    xml =  load_xml_from_request(@request.body.read, @request.params) 
    #puts "xmlpassed: #{xml}"
    #create xmlrpc request call
    call = XMLRPC::Marshal.load_call(xml)
    
    # convert *.getPost to get_post
    method = call[0].gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase
    
    # if the payload is empty raise an error back to the client
    halt 200, {'Content-Type' => 'text/xml'}, raise_xmlrpc_error("no information has been sent") if xml.empty?
    
    # get the autentication details see - metaweblog module method
    authentication_details = authentication_details_lookup(method, call)
    
    #if authentication fails inform the client
    halt 200, {'Content-Type' => 'text/xml'}, raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(authentication_details) || does_not_need_authentication?(method)
    
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
  
  helpers do
      def partial (template, locals = {})
        haml(template, :layout => false, :locals => locals)
      end
  end
    
end