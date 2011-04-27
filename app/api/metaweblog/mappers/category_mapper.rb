class CategoryMapper

  def initialize(xmlrpc_call)
    @xmlrpc_call = xmlrpc_call
  end

  def new_category_from_xmlrpc_payload
    Category.first_or_create({:category => @xmlrpc_call[1][3]['name']}, {:category => @xmlrpc_call[1][3]['name']})
  end

  def edit_category_from_xmlrpc_payload
    category = Category.get(@xmlrpc_call[1][3]['category_id'])
    category.category = @xmlrpc_call[1][3]['category']
    category
  end

  def mark_as_inactive_from_xmlrpc_payload
    category = Category.first({:id => @xmlrpc_call[1][3]})
    category.is_active = false unless category.posts.any?
    category.save
    !category.is_active
  end

end
