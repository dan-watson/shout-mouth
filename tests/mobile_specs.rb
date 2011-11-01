require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "Mobile devise detection" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end

  it "should add the mobile stylesheet when a mobile device visits the site" do
   header "User-Agent", "Apple-iPhone3C1/801.293"
   get '/404'
   last_response.body.should include("mobile.css")
  end

  it "should not add the mobile stylesheet when a mobile device visits the site" do
   header "User-Agent", "Lynx/2.8.8dev.3 libwww-FM/2.14 SSL-MM/1.4.1"
   get '/404'
   last_response.body.should_not include("mobile.css")
  end
end
