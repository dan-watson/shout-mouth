require Dir.pwd + '/app/models/post'

class Tag
  def self.all_tags
    tags = []
    Post.all_active_posts.each{|post| tags << post.tags}
    tags.flatten.uniq.sort
  end

  def self.posts_for_tag(tag)
    posts = []
    Post.all_active_posts.each{|post| posts << post if post.tags.include?(tag)}
    posts
  end

end
