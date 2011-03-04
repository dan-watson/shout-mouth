class WordpressStrategy < DefaultStrategy

  def authentication_details_from(method, xmlrpc_call)
    return {:username => xmlrpc_call[1][0], :password => xmlrpc_call[1][1]} if method == "get_users_blogs"
    super(method, xmlrpc_call)
  end

end
