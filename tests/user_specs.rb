require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require File.dirname(__FILE__) + '/test_data/test_data.rb'

require 'rspec'

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
    user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
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
  
  it "should not be able to change the set values for an already saved user" do
    user = User.new(:email => "test@rails.com", :password => "password@1")
    user.save
    
    lambda { user.salt = "" }.should raise_error(NoMethodError)
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

describe User, "querying" do
  before(:all) do
   valid_user = Factory(:valid_user)
   valid_user.save  
  
   inactive_user = Factory(:inactive_user)
   inactive_user.save
  
  end
  it "should not pull back inactive users" do
    all_users = User.all.count
    active_users = User.all_active.count
    active_users.should be < all_users
  end
end