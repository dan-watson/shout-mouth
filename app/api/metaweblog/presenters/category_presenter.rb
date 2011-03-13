class CategoryPresenter

  def initialize(category)
    @category = category
  end


  def to_minimal_metaweblog
    {
      :category_id => @category.id.to_s,
      :category_name => @category.category
    }
  end

  def to_movable_type_category_list_item
    {
      :categoryId => @category.id.to_s,
      :categoryName => @category.category
    }
  end

  def to_metaweblog
    {
      :categoryId => @category.id.to_s,
      :parentId => 0.to_s,
      :description => @category.category,
      :categoryDescription => "",
      :categoryName => @category.category,
      :htmlUrl => @category.permalink,
      :rssUrl => "",
      #:title => category #do we need this? not part of the wordpress api but is part of wordpress
    }
  end

  def to_movable_type_post_category
    {
      :categoryName => @category.category,
      :categoryId => @category.id.to_s,
      :isPrimary => false
    }
  end
end
