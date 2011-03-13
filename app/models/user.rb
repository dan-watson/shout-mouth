require 'digest/sha1'
require Dir.pwd + '/app/models/base/shout_record'

class User
  include Shout::Record

  property :firstname, String
  property :lastname, String
  property :email, String
  property :password, Object
  property :salt, Object, :writer => :private

  validates_presence_of :firstname, :lastname, :email, :password
  validates_format_of :email, :as => :email_address

  has n, :posts

  def initialize(attributes = nil)
    super(attributes)

    if new?
      self.salt = generate_salt

      if attributes && attributes.has_key?(:password)
        self.password = encrypt_password attributes[:password], self.salt
      end

    end
  end

  def self.find_user email
    User.first(:email => email, :is_active => true)
  end

  def authenticate password
    encrypt_password(password, self.salt) == self.password
  end

  def fullname
    "#{firstname} #{lastname}"
  end

  def to_metaweblog
    {
      :nickname => fullname,
      :userid => id.to_s,
      :url => Blog.url,
      :lastname => lastname,
      :firstname => firstname
      #:email => email
    }
  end

  def to_wordpress_author
    {
      :user_id => id.to_s,
      :user_login => email,
      :display_name => fullname,
      :user_email => email
      #:meta_value => ""
    }
  end

  private

  def generate_salt
    (0...8).map{rand(25).chr}.join
  end

  def encrypt_password password, salt
    Digest::SHA1.hexdigest(password + salt)
  end
end
