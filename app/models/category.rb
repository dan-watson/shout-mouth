require Dir.pwd + '/app/models/base/shout_record'

class Category
  include Shout::Record
    
    property :category, String, :length => 1000
    has n,   :posts, :through => Resource, :is_active => true
    
    def self.categories_from_array(array)
        categories = []
        array.each{|category| categories << Category.first_or_create({:category => category}, {:category => category})}
        categories
    end
    
    def self.usable_active_categories
      all_active.all(:category.not => "page")
    end
end
