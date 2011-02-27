require File.dirname(__FILE__) + '/../app/shout_mouth.rb'

require 'rspec'


describe Blog, "configuration" do
  it "should return the correct configuration variable for the Url" do
    Blog.url.should == "http://192.168.1.68:9393"
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
end