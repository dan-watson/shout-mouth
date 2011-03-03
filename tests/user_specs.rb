require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe User, "validation" do
  it "should not be valid if the email address and password are not present" do
    user = User.new
    user.should_not be_valid
  end
  
  it "should not be valid if the email address given is not a valid email address" do
    user = TestDataHelper.invalid_user
    user.should_not be_valid
    user.errors.full_messages.should include("Email has an invalid format")
  end
  
  it "should be valid if the required field and email address are supplied correctly" do
    user = TestDataHelper.valid_user
    user.should be_valid
  end
end

describe User, "defaults" do
  
  before(:all) do
    @user = TestDataHelper.valid_user
  end
  
  it "should have the active flag set to true" do
    @user.is_active.should be_true
  end
  
  it "should have an eight character random salt" do
    @user.salt.length.should == 8
  end
  
  it "should not be able to change the set values for an already saved user" do
    lambda { @user.salt = "" }.should raise_error(NoMethodError)
  end
end


describe User, "encryption and authentication" do
  
  before(:all) do
    @user = TestDataHelper.valid_user
  end
  
  it "should encrypt the plain password on creation" do
    @user.password.should_not == Factory(:valid_user).password
  end
  
  it "should be able to authenticate the user against the encrypted password" do
    @user.authenticate(Factory(:valid_user).password).should be_true
  end
end

describe User, "querying" do
  before(:all) do
    TestDataHelper.valid_user
    TestDataHelper.inactive_user
  end
  it "should not pull back inactive users" do
    User.all_active.count.should be < User.all.count 
  end
end