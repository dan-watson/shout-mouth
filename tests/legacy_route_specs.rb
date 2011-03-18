require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "Catching all legacy routes" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  

  it "should invoke the url action that will catch all when no other matching route is defined" do
        get '/some-legacy-some-random.aspx'
        last_response.status.should == 404
  end
  
  it "should redirect a legancy post to its new url" do
      #arrange
      legacy_route = TestDataHelper.legacy_route
      #act
      get "/#{legacy_route.slug}"
      
      #assert
      last_response.headers["Location"].should include legacy_route.post.persisted_slug
      last_response.should be_redirect
  end
end