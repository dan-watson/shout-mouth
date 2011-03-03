require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'



describe Comment, "validation" do
  it "should not be valid if the email address and comment are not present" do
    comment = Comment.new
    comment.should_not be_valid
  end

  it "should not be valid if the email address given is not a valid email address" do
    comment = TestDataHelper.invalid_comment_invalid_email
    comment.should_not be_valid
    comment.errors.full_messages.should include("Comment author email has an invalid format")
  end

  it "should be valid if the required fields and email address are supplied correctly" do
    TestDataHelper.valid_comment.should be_valid
  end
end

describe Comment, "defaults" do
  it "should have the active flag set to true" do
    comment = TestDataHelper.valid_comment
    comment.is_active.should be_true
  end

  it "should have the created_at date and time set" do
    comment = TestDataHelper.valid_comment
    comment.created_at.should_not be_nil
  end
end

describe Comment, "spam checker" do

  before(:all) do
    #yay for rubys open classes....
    class Blog
      def self.check_spam
        true
      end
    end
  end

  after(:all) do
    #one more time 
    class Blog
      def self.check_spam
        configuration['check_spam']
      end
    end
  end

  it "should return spam if the author name is viagra-test-123" do
    #arrange
    Akismetor.should_receive(:spam?).and_return(true)
    #Assert
    TestDataHelper.spam_comment.is_spam?.should be_true
  end

  it "should return ham if the comment is valid" do
    #arrange
    #Need to make sure save will be called
    TestDataHelper.wipe_database
    Akismetor.should_receive(:spam?).and_return(false)
    
    #Assert
    TestDataHelper.valid_comment.is_spam?.should be_false

  end
end

describe Comment, "querying" do
  before(:all) do
    TestDataHelper.wipe_database
    TestDataHelper.inactive_comment
    TestDataHelper.valid_comment
  end
  it "should not pull back inactive and spam comments" do
    Comment.all_active_and_ham.count.should == 1
  end
end
