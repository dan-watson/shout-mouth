class BloggerStrategy < DefaultStrategy
  
  def authentication_details_from(method, xmlrpc_call)
    
    case method
      when "get_recent_posts", "get_post", "set_template", "get_template", "new_post", "edit_post", "delete_post"
        {:username => xmlrpc_call[1][2], :password => xmlrpc_call[1][3]} 
      else
        #Better to be explicit here
        super(method,xmlrpc_call)
    end
  end
  
end