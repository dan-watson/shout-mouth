require 'factory_girl'

Factory.define :valid_user, :class => User do |f|
  f.email 'dan@shout_mouth.com'
  f.password 'password123'
  f.firstname 'Daniel'
  f.lastname 'Watson'
end

Factory.define :inactive_user, :class => User do |f|
  f.email 'dan@shout_mouth.com'
  f.password 'password123'
  f.firstname 'Daniel'
  f.lastname 'Watson'
  f.is_active false
end

Factory.define :valid_post, :class => Post do |f|
  f.title 'This is how we roll'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
  f.tags 'tag1, tag2'
  f.categories 'cat1, cat2'
  f.association :user, :factory => :valid_user
end

Factory.define :inactive_post, :class => Post do |f|
  f.title 'This is how we roll'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
  f.tags 'tag1, tag2'
  f.categories 'cat1, cat2'
  f.association :user, :factory => :valid_user
  f.is_active false
end

Factory.define :valid_page, :class => Post do |f|
  f.title 'Page Test'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
  f.tags 'page'
  f.categories 'page'
  f.is_page true
  f.association :user, :factory => :valid_user
end


Factory.define :valid_comment, :class => Comment do |f|
  f.comment_author 'Ham Ok'
  f.comment_author_email 'ham@ok.com'
  f.comment_author_url 'http://myblog.com'
  f.comment_content 'This is something that needs more discussion!'
  f.association :post, :factory => :valid_post
end

Factory.define :inactive_comment, :class => Comment do |f|
  f.comment_author 'Ham Ok'
  f.comment_author_email 'ham@ok.com'
  f.comment_author_url 'http://myblog.com'
  f.comment_content 'This is something that needs more discussion!'
  f.association :post, :factory => :valid_post
  f.is_active false
end

Factory.define :spam_comment, :class => Comment do |f|
  f.comment_author 'Ham Ok'
  f.comment_author_email 'ham@ok.com'
  f.comment_author_url 'http://myblog.com'
  f.comment_content 'This is something that needs more discussion!'
  f.association :post, :factory => :valid_post
  f.is_spam true
  f.is_active false
end


Factory.define :valid_legacy_route, :class => LegacyRoute  do |f|
  f.slug 'some-legacy-post.aspx'
  f.association :post, :factory => :valid_post
end
  