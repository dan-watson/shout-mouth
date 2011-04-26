class TagMapper
  
  def initialize(xmlrpc_call)
    @xmlrpc_call = xmlrpc_call
  end

  def new_category_from_xmlrpc_payload
    Category.first_or_create({:category => @xmlrpc_call[1][3]['name']}, {:category => @xmlrpc_call[1][3]['name']})
  end

  def edit_tag_from_xmlrpc_payload
    tag = Tag.get(@xmlrpc_call[1][3]['tag_id'])   
    tag.tag = @xmlrpc_call[1][3]['name']
    tag
   end
end
