require 'rspec'
require File.dirname(__FILE__) + '/../models/user'

describe User, "validation" do
  it "should not be valid if the email address and password are not present" do
    user = User.new
    user.should_not be_valid
  end
  
  it "should not be valid if the email address given is not a valid email address" do
    user = User.new(:email => "hkln/c/.com")
    user.should_not be_valid
  end
  
  it "should be valid if the required field and email address are supplied correctly" do
    user = User.new(:email => "test@rails.com", :password => "password@1")
    user.should be_valid
  end
end

describe User, "defaults" do
  it "should have the active flag set to true" do
    user = User.new(:email => "test@rails.com", :password => "password@1")
    user.is_active.should be_true
  end
  
  it "should have an eight character random salt" do
    user = User.new(:email => "test@rails.com", :password => "password@1")
    user.salt.length.should == 8
  end
  
  it "should not be able to change the default values for an already saved user" do
    user = User.new(:email => "test@rails.com", :password => "password@1")
    user.save
    
    lambda { user.salt = "" }.should raise_error(NoMethodError)
    lambda { user.created_at = DateTime.now }.should raise_error(NoMethodError)
  end
  
  after(:all) do
      User.all.each{|user| user.destroy}
  end
end


describe User, "encryption and authentication" do
  it "should encrypt the plain password on creation" do
    user = User.new(:email => "dan@d.com", :password => "passwwwwooord")
    user.password.should_not == "passwwwwooord"
  end
  
  it "should be able to authenticate the user against the encrypted password" do
    user = User.new(:email => "dan@d.com", :password => "pass")
    user.authenticate("pass").should be_true
  end
end
