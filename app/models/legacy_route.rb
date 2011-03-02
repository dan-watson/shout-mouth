require_relative 'base/shout_record'

class LegacyRoute
  include Shout::Record
  
  property :slug, String, :length => 1000
  
  belongs_to :post
  
end