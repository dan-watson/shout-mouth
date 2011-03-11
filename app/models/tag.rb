require Dir.pwd + '/app/models/base/shout_record'

class Tag
  include Shout::Record

  property :tag, String, :length => 1000
  has n,   :posts, :through => Resource, :is_active => true, :order => [ :created_at.desc ]
  
  validates_uniqueness_of :tag
  
  def self.tags_from_array(array)
    array.map{|tag| Tag.first_or_create({:tag => tag.strip}, {:tag => tag.strip})}
  end
  
  def self.usable_active_tags
    all.posts #need to force dynamic creation of the tag_posts class - this does not fire a query
    all_active.all(:tag.not => "page", :post_tags => {:post => { :is_active => true }}, :order => [:tag.asc])
  end
  
  def permalink
     "#{Blog.url}/tag/#{tag}" 
  end
  
  def to_metaweblog
    {
      :tag_id => id.to_s,
      :name => tag,
      :count => posts.count.to_s,
      :slug => tag,
      :html_url => permalink,
      :rss_url => ""
    }
  end
  
end
