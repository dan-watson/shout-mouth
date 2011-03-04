class BloggerStrategy < DefaultStrategy
  
  def authentication_details_from(method, xmlrpc_call)
    #Better to be explicit here
    super(method,xmlrpc_call)
  end
  
end