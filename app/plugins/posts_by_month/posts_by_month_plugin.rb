class PostsByMonthPlugin < Plugin
  
  def data
    Post.month_year_counter
  end
  
end