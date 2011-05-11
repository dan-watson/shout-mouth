require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require 'rspec'


describe Blog, "configuration" do
  it "should return the correct configuration variable for the posts_on_home_page" do
    Blog.posts_on_home_page.should == 3
  end
  
  it "should return the correct configuration variable for the Url" do
    Blog.url.should == "http://shout_mouth.dev"
  end
  
  it "should return the correct configuration variable for the askimet key" do
    Blog.akismet_key.should == "123456789"
  end
  
  it "should return the correct configuration variable for the site_name key" do
    Blog.site_name.should == "Test Site"
  end
  
  it "should return the correct configuration variable for the site_description key" do
    Blog.site_description.should == "Description"
  end
  
  it "should return the correct configuration variable for the amazon_s3_key key" do
    Blog.amazon_s3_key.should == "NO"
  end
  
  it "should return the correct configuration variable for the amazon_s3_bucket key" do
    Blog.amazon_s3_bucket.should == "NO"
  end
  
  it "should return the correct configuration variable for the amazon_s3_file_location key" do
    Blog.amazon_s3_file_location.should == "http://s3.amazonaws.com/"
  end
  
  it "should return the correct configuration variable for the amazon_s3_secret_key key" do
    Blog.amazon_s3_secret_key.should == "NO"
  end
  
  it "should return the correct configuration variable for the twitter_account key" do
    Blog.twitter_account.should == "@twitter"
  end
  
  it "should return the correct configuration variable for the check_spam key" do
    Blog.check_spam.should == false
  end
  
  it "should return the correct configuration variable for the comments_open_for_days key" do
    Blog.comments_open_for_days.should == 14
  end
  
  it "should return the correct configuration variable for the use_file_based_storage key" do
    Blog.use_file_based_storage.should == true
  end
  
  it "should return the correct configuration variable for the footer_more_text key" do
    Blog.footer_more_text.should == "Footer More"
  end
  
  it "should return the correct configuration variable for the google_analytics_key" do
    Blog.google_analytics_key.should == "UA-0000000-0"
  end
  
  it "should return the use_google_analytics as true" do
    Blog.use_google_analytics.should be_true
  end
  
  it "should return the correct hash of smtp settings" do
    smtp_settings = Blog.smtp_settings
    smtp_settings[:host].should == "smtp.yourserver.com"
    smtp_settings[:port].should == "25"
    smtp_settings[:user].should == "user"
    smtp_settings[:password].should == "pass"
    smtp_settings[:domain].should == "yourserver.com"
    smtp_settings[:auth].should == :plain
  end
  
  it "should return the correct site email addresss" do
    Blog.site_email.should == "user@yourserver.com"
  end
  
  it "should return the correct administrator email" do
    Blog.administrator_email.should == "admin@yourserver.com"
  end
  
end
