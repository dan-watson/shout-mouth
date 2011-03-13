require 'aws/s3'

class AmazonS3
  def self.save_file(name, bits)
    AWS::S3::Base.establish_connection!(
               :access_key_id     => Blog.amazon_s3_key, 
               :secret_access_key => Blog.amazon_s3_secret_key
             )
    AWS::S3::S3Object.store(name, bits, Blog.amazon_s3_bucket, :access => :public_read)
    {:file => name, :url => "#{Blog.amazon_s3_file_location}#{Blog.amazon_s3_bucket}/#{name}"}
  end
end