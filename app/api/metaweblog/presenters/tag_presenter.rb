class TagPresenter
  
  def initialize(tag)
    @tag = tag
  end
  
  def to_metaweblog
    {
      :tag_id => @tag.id.to_s,
      :name => @tag.tag,
      :count => @tag.posts.count.to_s,
      :slug => @tag.tag,
      :html_url => @tag.permalink,
      :rss_url => ""
    }
  end
  
end