require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'xmlrpc/marshal'
require Dir.pwd + '/app/models/base/shout_record'
require Dir.pwd + '/app/models/user'
require Dir.pwd + '/app/models/post'
require Dir.pwd + '/app/models/comment'
require Dir.pwd + '/app/models/legacy_route'
require Dir.pwd + '/app/models/blog'
require Dir.pwd + '/app/models/tag'
require Dir.pwd + '/app/models/category'
require Dir.pwd + '/app/api/metaweblog/metaweblog'
require Dir.pwd + '/app/lib/fixnum'

class ShoutMouth < Sinatra::Base
  include Metaweblog

  set :public, File.dirname(__FILE__) + '/../public'
  set :views, File.dirname(__FILE__) + '/views'

  get '/' do
    prepend_title("Home")
    @articles = Post.all_active_posts.all(:limit => Blog.posts_on_home_page.to_i)
    halt haml :index unless @articles.none?
    haml :nodata
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
    comment = Comment.new(params[:comment].merge(
    {
      :user_ip => request.ip,
      :user_agent => request.user_agent,
      :referrer => request.referer,
      :post => Post.find(:persisted_slug => params[:slug]).first
    }))
    #even if the comment is marked as spam send it back so it will show on the page to satisfy the spammer / bot has
    #done its job correctly
    comment.save ? comment.to_simple_comment.to_json :  comment.errors.map{|error| {:error => error}}.to_json
  end


  get '/category/:category' do
    prepend_title(params[:category])
    @posts = Category.all(:category => params[:category]).posts
    haml :archive
  end

  get '/tag/:tag' do
    prepend_title(params[:tag])
    @posts = Tag.all(:tag => params[:tag]).posts
    haml :archive
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

  get '/rss' do
    content_type 'application/rss+xml'
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
  get '/404' do
    haml :not_found
  end

  get '/*' do
    legacy_route = LegacyRoute.first(:slug => params[:splat])
    redirect legacy_route.post.permalink, 301 unless legacy_route.nil?
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
    authentication_details = authentication_details_from(method, call)

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

    def title
      @title.nil? ? Blog.site_name : @title
    end

    def prepend_title title
      @title = "#{title} - #{Blog.site_name}"
    end

    def all_tags
      Tag.usable_active_tags
    end

    def month_roll
      Post.month_year_counter
    end
    
    def pages
      Post.all_active_pages
    end
  end
end
