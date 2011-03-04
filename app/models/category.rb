require Dir.pwd + '/app/models/base/shout_record'

class Category
  include Shout::Record
    
    property :category, String, :length => 1000
    has n,   :posts, :through => Resource, :is_active => true, :order => [ :created_at.desc ]
    
    def self.categories_from_array(array)
        array.map{|category| Category.first_or_create({:category => category}, {:category => category})}
    end
    
    def self.usable_active_categories
      all.posts #need to force dynamic creation of the category posts class - this does not fire a query
      all_active.all(:category.not => "page", :category_posts => { :post => { :is_active => true }})
    end
end
