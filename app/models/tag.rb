require Dir.pwd + '/app/models/base/shout_record'

class Tag
  include Shout::Record

  property :tag, String, :length => 1000
  has n,   :posts, :through => Resource, :is_active => true
  
  validates_uniqueness_of :tag
  
  def self.tags_from_array(array)
    tags = []
    array.each{|tag| tags << Tag.first_or_create({:tag => tag}, {:tag => tag})}
    tags
  end
  
  def self.usable_active_tags
    all_active.all(:tag.not => "page")
  end
end
