require_relative 'post'

class Tag
  def self.all_tags
      tags = []
      Post.all_active_posts.each{|post| tags << post.tags}
      tags.flatten.uniq.sort
  end
end