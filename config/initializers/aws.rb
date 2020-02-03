Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
  endpoint:'https://s3.us-east-1.amazonaws.com'
})

S3 = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])