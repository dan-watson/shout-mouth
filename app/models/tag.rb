require Dir.pwd + '/app/models/base/shout_record'

class Tag
  include Shout::Record

  property :tag, String, :length => 1000
  property :persisted_slug, String, :length => 1000
  
  has n,   :posts, :through => Resource, :is_active => true, :order => [ :created_at.desc ]

  validates_uniqueness_of :tag

  before :save do
    self.persisted_slug = self.slug
  end

  #Instance Methods
  def permalink
    "#{Blog.url}#{link}"
  end
  
  def link
    "/tag/#{slug}"
  end
  
  def slug
    to_url_safe_string tag
  end
  
  #Factory Methods Input
  def self.tags_from_array(array)
    array.map{|tag| Tag.first_or_create({:tag => tag.strip}, {:tag => tag.strip})}
  end

  #Factor Methods Output
  def self.usable_active_tags
    all.posts #need to force dynamic creation of the tag_posts class - this does not fire a query
    all_active.all(:tag.not => "page", :post_tags => {:post => { :is_active => true , :created_at.lte => Time.now }}, :order => [:tag.asc])
  end

end
