require Dir.pwd + '/app/models/post'

class Category

  def self.all_categories
    categories = []
    Post.all_active_posts.each{|post| categories << post.categories}
    categories.flatten.uniq
  end

  def self.posts_for_category(category)
    posts = []
    Post.all_active_posts.each{|post| posts << post if post.categories.include?(category)}
    posts
  end

end
