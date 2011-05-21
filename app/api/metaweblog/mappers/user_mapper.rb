class UserMapper

  def initialize(xmlrpc_call)
    @xmlrpc_call = xmlrpc_call
  end

  def new_user_from_xmlrpc_payload
    data = @xmlrpc_call[1][3]
    User.new(:email => data["email"], :password => data["password"], :firstname => data["firstname"], :lastname => data["lastname"])
  end

  def edit_user_from_xmlrpc_payload
    data = @xmlrpc_call[1][3]
    user = User.get(data["user_id"])
    user.email = data["email"]
    user.firstname = data["firstname"]
    user.lastname = data["lastname"]
    user.encrypt_password_from_plain data["password"]
    user
  end

  def delete_user_from_xmlrpc_payload
    user_id = @xmlrpc_call[1][3]
    user = User.get(user_id)
    user.is_active = false
    user.save
  end

end
