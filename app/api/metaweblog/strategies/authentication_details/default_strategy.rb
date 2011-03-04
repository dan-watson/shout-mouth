class DefaultStrategy
  def authentication_details_from(method, xmlrpc_call)
    case method
    when "delete_post", "get_page", "edit_page"
      {:username => xmlrpc_call[1][2], :password => xmlrpc_call[1][3]}
    else
      {:username => xmlrpc_call[1][1], :password => xmlrpc_call[1][2]}
    end
  end

end
