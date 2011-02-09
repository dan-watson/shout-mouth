require 'factory_girl'

Factory.define :valid_user, :class => User do |f|
  f.email 'dan@shout_mouth.com'
  f.password 'password123'
end

Factory.define :valid_post, :class => Post do |f|
  f.title 'This is how we roll'
  f.body 'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin malesuada imperdiet est convallis cursus. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed vulputate sagittis pharetra. In luctus, odio sed commodo cursus, quam eros bibendum mi, at laoreet leo sapien eget enim. Nunc iaculis augue in arcu consequat pellentesque. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin eu ante id tortor congue lacinia eget a quam. In tristique dui ut metus tempor dignissim sodales arcu tincidunt. Praesent volutpat venenatis neque, ut cursus velit cursus et. Proin varius lorem ut velit dignissim vulputate. Curabitur pellentesque interdum tincidunt. Etiam blandit feugiat erat, in elementum nisi ornare a. Etiam diam lectus, sagittis et hendrerit sed, feugiat vel purus. Mauris pharetra congue risus, sit amet pulvinar massa tempus rutrum. Proin sit amet semper ipsum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
  f.association :user, :factory => :valid_user
end

Factory.define :valid_comment, :class => Comment do |f|
  f.email 'ham@ok.com'
  f.comment 'This is something that needs more discussion!'
  f.association :post, :factory => :valid_post
end

Factory.define :valid_legacy_route, :class => LegacyRoute  do |f|
  f.slug 'some-legacy-post.aspx'
  f.association :post, :factory => :valid_post
end
  
