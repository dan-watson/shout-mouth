
class TwitterPlugin < Plugin
  def data
    Blog.twitter_account
  end
end