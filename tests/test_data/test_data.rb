require 'factory_girl'

Factory.define :valid_user, :class => User do |f|
  f.email 'dan@shout_mouth.com'
  f.password 'password123'
  f.firstname 'Daniel'
  f.lastname 'Watson'
end

Factory.define :invalid_user_invalid_email, :class => User do |f|
  f.email 'invaliddan'
  f.password 'password123'
  f.firstname 'Daniel'
  f.lastname 'Watson'
end

Factory.define :inactive_user, :class => User do |f|
  f.email 'inactuvedan@shout_mouth.com'
  f.password 'password123'
  f.firstname 'Daniel'
  f.lastname 'Watson'
  f.is_active false
end

Factory.define :valid_post, :class => Post do |f|
  f.title 'This is how we roll'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
end

Factory.define :valid_post_1, :class => Post do |f|
  f.title 'New Post 1'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
end

Factory.define :valid_post_2, :class => Post do |f|
  f.title 'New Post 2'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
end

Factory.define :inactive_post, :class => Post do |f|
  f.title 'Inactive This is how we roll'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
  f.is_active false
end

Factory.define :valid_page, :class => Post do |f|
  f.title 'Valid Page'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
  f.is_page true
end


Factory.define :valid_comment, :class => Comment do |f|
  f.comment_author 'Ham Ok'
  f.comment_author_email 'ham@ok.com'
  f.comment_author_url 'http://myblog.com'
  f.comment_content 'This is something that needs more discussion!'
  f.is_spam false
  f.is_active true
  f.user_ip "192.168.1.68"
end

Factory.define :invalid_comment_invalid_email, :class => Comment do |f|
  f.comment_author 'Ham Ok'
  f.comment_author_email 'ha**cd/??//m'
  f.comment_author_url 'http://myblog.com'
  f.comment_content 'This is something that needs more discussion! Bad Email'
  f.user_ip "192.168.1.68"
end

Factory.define :inactive_comment, :class => Comment do |f|
  f.comment_author 'Ham Ok'
  f.comment_author_email 'ham@ok.com'
  f.comment_author_url 'http://myblog.com'
  f.comment_content 'This is something that needs more discussion! Inactive'
  f.is_active false
  f.is_spam true
  f.user_ip "192.168.1.68"
end

Factory.define :spam_comment, :class => Comment do |f|
  f.comment_author 'viagra-test-123'
  f.comment_author_email 'spam@ok.com'
  f.comment_author_url 'http://little-spammy.com'
  f.comment_content 'This is something that needs more discussion! Spammer'
  f.is_spam true
  f.is_active true
  f.user_ip "192.168.1.68"
end


Factory.define :legacy_route, :class => LegacyRoute  do |f|
  f.slug 'some-legacy-post.aspx'
end
  
Factory.define :category_1, :class => Category do |f|
  f.category 'category1'
end

Factory.define :category_2, :class => Category do |f|
  f.category 'category2'
end

Factory.define :category_3, :class => Category do |f|
  f.category 'category3'
end

Factory.define :category_4, :class => Category do |f|
  f.category 'category4'
end

Factory.define :page_category, :class => Category do |f|
  f.category 'page'
end

Factory.define :tag_1, :class => Tag do |f|
  f.tag 'tag1'
end

Factory.define :tag_2, :class => Tag do |f|
  f.tag 'tag2'
end

Factory.define :tag_3, :class => Tag do |f|
  f.tag 'tag3'
end

Factory.define :tag_4, :class => Tag do |f|
  f.tag 'tag4'
end

Factory.define :page_tag, :class => Tag do |f|
  f.tag 'page'
end