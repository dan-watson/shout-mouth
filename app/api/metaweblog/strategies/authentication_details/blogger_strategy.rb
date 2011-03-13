class BloggerStrategy < DefaultStrategy
  
  def authentication_details_from(method, xmlrpc_call)
    return {:username => xmlrpc_call[1][2], :password => xmlrpc_call[1][3]} if method == "get_recent_posts" || method == "get_post"
    #Better to be explicit here
    super(method,xmlrpc_call)
  end
  
end