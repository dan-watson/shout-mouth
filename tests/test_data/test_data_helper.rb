require File.dirname(__FILE__) + '/../../app/shout_mouth.rb'
require File.dirname(__FILE__) + '/test_data.rb'
require 'factory_girl'
require 'rspec'
require 'rack/test'
require 'nokogiri'

ENV['RACK_ENV'] = 'test'

class TestDataHelper
    
  def self.wipe_database
    Comment.destroy
    User.destroy
    Post.destroy
    Category.destroy
    Tag.destroy
  end
  
  #Settings
  def self.settings
   settings = {
      "posts_on_home_page"=>3, 
      "site_name"=>"Test Site", 
      "url"=>"http://shout_mouth.dev", 
      "site_description"=>"Description", 
      "akismet_key"=>"123456789", 
      "amazon_s3_key"=>"NO", 
      "amazon_s3_secret_key"=>"NO", 
      "amazon_s3_bucket"=>"NO", 
      "amazon_s3_file_location"=>"http://s3.amazonaws.com/", 
      "theme"=>"default", 
      "twitter_account"=>"@twitter", 
      "check_spam"=>false, 
      "comments_open_for_days"=>14, 
      "use_file_based_storage"=>true, 
      "footer_more_text"=>"Footer More", 
      "google_analytics_key"=>"UA-0000000-0", 
      "smtp_host"=>"smtp.yourserver.com", 
      "smtp_port"=>"25", 
      "smtp_user"=>"user", 
      "smtp_password"=>"pass", 
      "smtp_domain"=>"yourserver.com", 
      "site_email"=>"user@yourserver.com", 
      "administrator_email"=>"admin@yourserver.com"
   }

   settings.each{|setting|
     Blog.send("#{setting[0]}=", setting[1])
   }
  end

  #Users
  def self.valid_user
    user = Factory.build(:valid_user)
    User.first_or_create({:email => user.email}, user.attributes.keep_if{|attribute| attribute != :salt})
  end
  
  def self.inactive_user
    user = Factory.build(:inactive_user)
    User.first_or_create({:email => user.email}, user.attributes.keep_if{|attribute| attribute != :salt})
  end
  
  def self.invalid_user
    Factory.build(:invalid_user_invalid_email)
  end
  
  #Categories
  def self.category1
    category = Factory.build(:category_1)
    Category.first_or_create({:category => category.category}, category.attributes)
  end
  
  def self.category2
    category = Factory.build(:category_2)
    Category.first_or_create({:category => category.category}, category.attributes)
  end
  
  def self.category3
    category = Factory.build(:category_3)
    Category.first_or_create({:category => category.category}, category.attributes)
  end
  
  def self.category4
    category = Factory.build(:category_4)
    Category.first_or_create({:category => category.category}, category.attributes)
  end
  
  def self.page_category
    category = Factory.build(:page_category)
    Category.first_or_create({:category => category.category}, category.attributes)
  end
  
  #Tags
  def self.tag1
    tag = Factory.build(:tag_1)
    Tag.first_or_create({:tag => tag.tag}, tag.attributes)
  end
  
  def self.tag2
    tag = Factory.build(:tag_2)
    Tag.first_or_create({:tag => tag.tag}, tag.attributes)
  end
  
  def self.tag3
    tag = Factory.build(:tag_3)
    Tag.first_or_create({:tag => tag.tag}, tag.attributes)
  end
  
  def self.tag4
    tag = Factory.build(:tag_4)
    Tag.first_or_create({:tag => tag.tag}, tag.attributes)
  end
  
  def self.page_tag
    tag  = Factory.build(:page_tag)
    Tag.first_or_create({:tag => tag.tag}, tag.attributes)
  end
  
  #Posts
  def self.valid_post                                     
    Post.first_or_create({:title => Factory.build(:valid_post).title}, Factory.build(:valid_post).attributes.merge({:user => TestDataHelper.valid_user, 
                                                             :categories => [TestDataHelper.category1,TestDataHelper.category2],
                                                             :tags => [TestDataHelper.tag1, TestDataHelper.tag2]}))
  end
  
  def self.valid_post1
    Post.first_or_create({:title => Factory.build(:valid_post_1).title}, Factory.build(:valid_post_1).attributes.merge({:user => TestDataHelper.valid_user, 
                                                               :categories => [TestDataHelper.category1,TestDataHelper.category2],
                                                               :tags => [TestDataHelper.tag1, TestDataHelper.tag2]}))
  end
  
  def self.valid_post2
    Post.first_or_create({:title => Factory.build(:valid_post_2).title}, Factory.build(:valid_post_2).attributes.merge({:user => TestDataHelper.valid_user, 
                                                               :categories => [TestDataHelper.category3,TestDataHelper.category4],
                                                               :tags => [TestDataHelper.tag3, TestDataHelper.tag4]}))
  end
  
  
  #Pages
  def self.valid_page
    Post.first_or_create({:title => Factory.build(:valid_page).title, :is_page => true}, Factory.build(:valid_page).attributes.merge({:user => TestDataHelper.valid_user, 
                                                               :categories => [TestDataHelper.page_category],
                                                               :tags => [TestDataHelper.page_tag]}))
  end
  
  #Comments
  
  def self.invalid_comment_invalid_email
    #dont bother saving it wont - its invalid
    Factory.build(:invalid_comment_invalid_email)
  end

  def self.valid_comment
    comment = Factory.build(:valid_comment)
    Comment.first_or_create({:comment_content => comment}, comment.attributes.merge({:post => TestDataHelper.valid_post}))
  end
  
  def self.spam_comment
    comment = Factory.build(:spam_comment)
    Comment.first_or_create({:comment_content => comment}, comment.attributes.merge({:post => TestDataHelper.valid_post}))
  end
  
  def self.inactive_comment
    comment = Factory.build(:inactive_comment)
    Comment.first_or_create({:comment_content => comment}, comment.attributes.merge({:post => TestDataHelper.valid_post}))
  end
  
  def self.load_all_comments
    valid_comment
    spam_comment
    inactive_comment
  end
  
  #Legacy Routes
  
  def self.legacy_route
    legacy_route = Factory.build(:legacy_route)
    LegacyRoute.first_or_create({:slug => legacy_route.slug}, legacy_route.attributes.merge({:post => TestDataHelper.valid_post}))
  end
end
