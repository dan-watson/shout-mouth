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

  it "should be able to create and retrieve a phantom key via method missing" do
    Blog.whats_the_time_mr_wolf = "10:00pm"
    Blog.whats_the_time_mr_wolf.should == "10:00pm"
  end
  
  it "setup should verify when not all the settings have been passed to the method that the method will return false" do
    settings = {}
    Blog.setup(settings).should == :invalid
  end

  it "should not allow invalid configuration settings to be created on setup" do
    settings = {"url"=>"httpsdfsdfsdf/", 
                "site_name"=>"", 
                "site_description"=>"", 
                "posts_on_home_page"=>"sdfdsf", 
                "footer_more_text"=>"", 
                "check_spam"=>"true", 
                "akismet_key"=>"", 
                "comments_open_for_days_check"=>"false", 
                "comments_open_for_days"=>"df", 
                "use_file_based_storage"=>"false",
                "amazon_s3_key"=>"", 
                "amazon_s3_secret_key"=>"", 
                "amazon_s3_bucket"=>"", 
                "amazon_s3_file_location"=>"",
                "theme"=>"", 
                "twitter_account"=>"", 
                "use_google_analytics"=>"true", 
                "google_analytics_key"=>"", 
                "smtp_host"=>"", 
                "smtp_port"=>"", 
                "smtp_user"=>"", 
                "smtp_password"=>"", 
                "smtp_auth"=>"plain", 
                "smtp_domain"=>"", 
                "site_email"=>"kdfm",
                "administrator_email"=>"dsfsdf", 
                "user"=>{"firstname"=>"", "lastname"=>"", "email"=>"sdfsdfs", "password"=>"sdf", "password_confirm"=>""},
                "categories" => ""}
    Blog.setup(settings).count.should == 25
    #Teardown
    TestDataHelper.settings
  end

  it "should create configuration settings when the settings are valid" do
    settings = {"url"=>"http://localhost", "site_name"=>"Sitename", "site_description"=>"Site description", "posts_on_home_page"=>"4", "footer_more_text"=>"Some more text", "check_spam"=>"true", "akismet_key"=>"1234567", "comments_open_for_days_check"=>"true", "comments_open_for_days"=>"5", "use_file_based_storage"=>"false", "amazon_s3_key"=>"key", "amazon_s3_secret_key"=>"secret key", "amazon_s3_bucket"=>"bucket", "amazon_s3_file_location"=>"http://s3.amazonaws.com/", "theme"=>"default", "twitter_account"=>"@twitter", "use_google_analytics"=>"true", "google_analytics_key"=>"UA-00001", "smtp_host"=>"host", "smtp_port"=>"89", "smtp_user"=>"user", "smtp_password"=>"pass", "smtp_auth"=>"plain", "smtp_domain"=>"domain", "site_email"=>"email@email.com", "administrator_email"=>"email@email.com", "user"=>{"firstname"=>"Daniel", "lastname"=>"Watson", "email"=>"setup@shoutmouth.com", "password"=>"Passed", "password_confirm"=>"Passed"}, "categories" => "dan , jake"}

    Blog.setup(settings)
    Blog.url.should == "http://localhost"
    Blog.site_name.should == "Sitename"
    Blog.site_description.should == "Site description"
    Blog.posts_on_home_page.should == 4
    Blog.footer_more_text.should == "Some more text"
    Blog.check_spam.should be_true
    Blog.akismet_key.should == "1234567"
    Blog.comments_open_for_days.should == 5
    Blog.use_file_based_storage.should == false
    Blog.amazon_s3_key.should == "key"
    Blog.amazon_s3_secret_key.should == "secret key"
    Blog.amazon_s3_bucket.should == "bucket"
    Blog.amazon_s3_file_location.should == "http://s3.amazonaws.com/"
    Blog.theme.should == "default"
    Blog.twitter_account.should == "@twitter"
    Blog.use_google_analytics.should be_true
    Blog.google_analytics_key.should == "UA-00001"
    Blog.smtp_settings[:host].should == "host"
    Blog.smtp_settings[:port].should == "89"
    Blog.smtp_settings[:user].should == "user"
    Blog.smtp_settings[:password].should == "pass"
    Blog.smtp_settings[:auth].should == :plain
    Blog.smtp_settings[:domain].should == "domain"
    Blog.site_email.should == "email@email.com"
    Blog.administrator_email.should == "email@email.com"

    Category.all[0].category.should == "dan"
    Category.all[1].category.should == "jake"

    user = User.first(:email => "setup@shoutmouth.com")
    user.firstname.should == "Daniel"
    user.lastname.should == "Watson"
    user.authenticate("Passed").should be_true

    Category.destroy
    TestDataHelper.settings
  end

end
