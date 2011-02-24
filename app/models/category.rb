require_relative 'post'

class Category
  
  def self.all_categories
    categories = []
    Post.all_active_posts.each{|post| categories << post.categories}
    categories.flatten.uniq
  end
end