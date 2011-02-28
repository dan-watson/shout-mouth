require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require File.dirname(__FILE__) + '/test_data/test_data.rb'

require 'rspec'
require 'rack/test'
require 'factory_girl'


describe "Catching all legacy routes" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  

  it "should invoke the url action that will catch all when no other matching route is defined" do
        get '/some-legacy-some-random.aspx'
        last_response.headers["Location"].should include "404"
  end
  
  it "should redirect a legancy post to its new url" do
      #arrange
      @legacy_route = Factory.create(:valid_legacy_route)
      LegacyRoute.should_receive(:first).with(:slug => ["some-legacy-post.aspx"]).and_return(@legacy_route)
      
      #act
      get '/some-legacy-post.aspx'
      
      #assert
      last_response.headers["Location"].should include "this-is-how-we-roll"
      last_response.should be_redirect
  end
end