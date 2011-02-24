require_relative 'base/shout_record'

class LegacyRoute
  include Shout::Record
  
  property :slug, String
  
  belongs_to :post
  
end