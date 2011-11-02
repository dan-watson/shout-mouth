require 'rubygems'
require 'sinatra'
require 'pony'
require 'haml'
require 'json'
require 'xmlrpc/marshal'
require Dir.pwd + '/app/models/base/shout_record'
require Dir.pwd + '/app/models/user'
require Dir.pwd + '/app/models/post'
require Dir.pwd + '/app/models/post_status'
require Dir.pwd + '/app/models/comment'
require Dir.pwd + '/app/models/legacy_route'
require Dir.pwd + '/app/models/blog'
require Dir.pwd + '/app/models/tag'
require Dir.pwd + '/app/models/category'
require Dir.pwd + '/app/api/metaweblog/metaweblog'
require Dir.pwd + '/app/lib/fixnum'
require Dir.pwd + '/app/lib/string'
require Dir.pwd + '/app/lib/object'
require Dir.pwd + '/app/lib/hash'
require Dir.pwd + '/app/lib/regexp'
require Dir.pwd + '/app/api/plugin/plugin_factory'
require Dir.pwd + '/app/api/command/command_handler'
require Dir.pwd + '/app/api/mobile_detector/mobile_detector'

DataMapper.finalize

class ShoutMouth < Sinatra::Base
  include Metaweblog
  include MobileDetector

  set :public_folder, File.dirname(__FILE__) + '/../public'
  set :views, File.dirname(__FILE__) + '/views'
  set :root, File.dirname(__FILE__)
  
  get '/' do
    
    begin
      #STOP legacy urls breaking the cache - eg http://www.yoursite.com?tags=gamer
      redirect "/notfound", 301 if params.length > 0
      
      prepend_title("Home")
      @articles = Post.all_active_posts.all(:limit => Blog.posts_on_home_page.to_i)
      halt haml :index unless @articles.none?
      haml :nodata
    rescue DataObjects::SyntaxError
      #A SQL syntax error is raised when the database has not been created..
      #This does not necessarily mean that we need to go into setup mode eg => (lost connection to db or even someone playing directly with tables....)
      #Lets make a second check to be sure.....
      #If the setup flag exists then lets go for it
      @errors = []
      @values = {"user" => ""}
      halt haml :setup, :layout => false if setup?
    end
  end

  post '/setup' do
    #Not a good idea to let people modify settings when setup has already been completed....
    if setup?
      response = Blog.setup(params)
      if response == true
        redirect "/"
      else
        @errors = response
        @values = params
        halt haml :setup, :layout => false
      end
    else
      redirect "/"
    end
  end

  #DRY - This route matches for both pages and posts as the program flow is the same
  ["/page/:slug", "/post/:year/:month/:day/:slug"].each do |path|
    get path do
      @article = Post.all_active.all(:persisted_slug => params[:slug]).first

      #throw the request to the catch all handler which will sort everything out
      if @article.nil?
        redirect "/#{params[:slug]}"
      end

      prepend_title(@article.title)
      halt haml :page if @article.is_page?
      haml :post
    end
  end

  post '/post/:slug/add_comment' do
    content_type :json
    
    post = Post.first(:persisted_slug => params[:slug])
    comment = params[:comment].merge(
    {
      :user_ip => request.ip,
      :user_agent => request.user_agent,
      :referrer => request.referer,
      :post => Post.first(:persisted_slug => params[:slug])
    })
    comment = post.add_comment comment
    #even if the comment is marked as spam send it back so it will show on the page to satisfy the spammer / bot has
    #done its job correctly
    if comment.valid?
      response.set_cookie("comment_user", :value => params[:comment].except("comment_content").to_query_string,
                                 :domain => request.host,
                                 :path => "/",
                                 :expires => Time.new + (60 * 60 * 24 * 365)) #1 Year

      comment.to_simple_comment.to_json
    else
      comment.errors.map{ |error| {:error => error}}.to_json
    end

  end


  get '/category/:category' do
    prepend_title(params[:category])
    category = Category.first(:persisted_slug => params[:category])
    
    unless category.nil?
      @posts = category.posts
      halt haml :archive
    end
    
    #If the category has been typed in by name or is legacy from an older version of shoutmouth
    #then send the browser to the new url safe version
    category = Category.first(:category => params[:category])
    redirect category.permalink, 301 unless category.nil?
    
    #When no category can be found - send to catch all route where a 404 will be returned.....
    redirect "/notfound", 301
  end

  get '/tag/:tag' do
    prepend_title(params[:tag])
    tag = Tag.first(:persisted_slug => params[:tag])

    unless tag.nil?
      @posts = tag.posts
      halt haml :archive
    end
    
    #If the tag has been typed in by name or is legacy from an older version of shoutmouth
    #then send the browser to the new url safe version    
    tag = Tag.first(:tag => params[:tag])
    redirect tag.permalink, 301 unless tag.nil?
    
    #When no tag can be found - send to catch all route where a 404 will be returned.....
    redirect "/notfound", 301
  end

  get '/posts/date/:year-:month' do
    prepend_title("Posts for #{params[:month]}-#{params[:year]}")
    @posts = Post.all_active_posts.all(:year => params[:year], :month => params[:month])
    haml :archive
  end

  get '/archive' do
    prepend_title("Archive")
    @posts = Post.all_active_posts
    haml :archive
  end

  get '/rss.xml' do
    content_type 'application/rss+xml'
    @posts = Post.all_active_posts
    builder :rss, :layout => false
  end

  get '/sitemap.xml' do
    content_type 'text/xml'
    @pages = Blog.urls
    builder :sitemap, :layout => false
  end

  get '/rsd.xml' do
    content_type 'text/xml'
    builder :rsd, :layout => false
  end

  #This method is to allow metaweblog clients to pick up the theme of the blog
  #Minimal amount of information supplied for the user and post just to get the template to render
  get '/webpreview.html' do
    @article = Post.new(:title => "{post-title}",
    :body => "{post-body}",
    :is_page => false,
    :created_at => DateTime.now,
    :tags => [Tag.new(:tag => "Tag1"), Tag.new(:tag => "Tag2")],
    :user => User.new(:firstname => "Shout", :lastname => "Mouth"))
    haml :preview
  end

  get %r{/xmlrpc([*.[a-z]/]+)} do
    "XML-RPC server accepts POST requests only."
  end

  # Catch All
  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    redirect legacy_route.post.permalink, 301 unless legacy_route.nil?    
    status 404
    haml :not_found
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
    call = XMLRPC::Marshal.load_call(xml.to_valid_xmlrpc_request)
    # convert *.getPost to get_post
    method = call[0].gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase

    # if the payload is empty raise an error back to the client
    halt 200, {'Content-Type' => 'text/xml'}, dump_response(raise_xmlrpc_error(-32700, "parse error. not well formed")) if xml.empty?

    # get the autentication details see - metaweblog module method
    authentication_details = authentication_details_from(method, call)

    #if authentication fails inform the client - authenticated? - metaweblog.rb
    halt 200, {'Content-Type' => 'text/xml'}, dump_response(raise_xmlrpc_error(403, "Bad login/pass combination.")) unless authenticated?(authentication_details) || does_not_need_authentication?(method)

    #if everything with the request is fine send the payload onto the method in the metaweblog module
    response.headers['Content-Type'] = 'text/xml;'
    begin
      data = send(method, call)
    rescue NoMethodError, RuntimeError
      halt 200, {'Content-Type' => 'text/xml'}, dump_response(raise_xmlrpc_error(-32601, "server error. requested method #{call[0]} does not exist."))
    end
    #metaweblog module method - to dump the data to an xmlrpc response
    dump_response(data)
  end

  private
  def load_xml_from_request request_body, request_params
    if request_body.empty?
      hash = request_params
      request_body = (hash.keys + hash.values).join
    end
    return request_body
  end
  
  helpers do
    def partial (template, locals = {})
      haml(template, :layout => false, :locals => locals)
    end
    
    def plugin(plugin_object, data = nil)
      view_data = data.nil? ? {:"#{plugin_object.plugin_name}" => plugin_object.data} : data
      haml(:"#{plugin_object.view_name}", {:layout => false, :views => plugin_object.view_directory}, view_data)
    end

    def title
      @title.nil? ? Blog.site_name : @title
    end

    def prepend_title title
      @title = "#{title} - #{Blog.site_name}"
    end

    def pages
      Post.all_active_pages.all(:parent_page_id => 0,:order => [:page_order.asc])
    end
    
    def meta_keywords
      Tag.usable_active_tags.map{|tag| tag.tag}.join(", ")
    end

    def setup?
      File.exists?(File.expand_path("../../setup", __FILE__))
    end
    
    def version
      "v2m0"
    end
  end
end
