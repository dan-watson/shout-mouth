require Dir.pwd + '/app/api/validator/validator'

class SetupValidator < Validator
  def validate(settings)
    #Settings needed to valid blog setup
    settings_needed = ["url", "site_name", "site_description", "posts_on_home_page", "footer_more_text", "check_spam", "akismet_key", "comments_open_for_days_check", 
                       "comments_open_for_days", "use_file_based_storage","amazon_s3_key", "amazon_s3_secret_key", "amazon_s3_bucket", "amazon_s3_file_location",
                       "theme", "twitter_account", "use_google_analytics", "google_analytics_key", "smtp_host", "smtp_port", "smtp_user", "smtp_password", "smtp_auth", 
                       "smtp_domain", "site_email", "administrator_email", "categories", "user"]
    #Validate all the settings needed for setup exist
    return :invalid unless settings.has_keys?(settings_needed)
    #Validate each setting has a valid value - could be split out into a seperate validation class to seperate concerns but going to inline it even
    #though the method is large it is more obvious what it going on.
    errors = []
    errors << "Valid site url is required" unless settings["url"].length > 0 && settings["url"] =~ Regexp.new(Regexp::URL)
    errors << "Site name is required" unless settings["site_name"].length > 0
    errors << "Site description is required" unless settings["site_description"].length > 0
    errors << "Posts on home page must be numeric" unless settings["posts_on_home_page"] !~ Regexp.new(Regexp::NUMERIC)
    errors << "Check spam must be true or false" unless settings["check_spam"] == "true" || settings["check_spam"] == "false"
    errors << "Akismet key is required" if settings["check_spam"] == "true" && settings["akismet_key"].length == 0 
    errors << "Comments open for days must be numeric" unless settings["comments_open_for_days"] !~ Regexp.new(Regexp::NUMERIC)
    errors << "Amazon S3 key is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_key"].length == 0
    errors << "Amazon S3 secret key is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_secret_key"].length == 0
    errors << "Amazon S3 bucket is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_bucket"].length == 0
    errors << "Amazon S3 file location is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_file_location"].length == 0
    errors << "Theme is required" unless settings["theme"].length > 0
    errors << "Twitter account is required" unless settings["twitter_account"].length > 0
    errors << "Google analytics key is required" if settings["use_google_analytics"] == "true" && settings["google_analytics_key"].length == 0
    errors << "SMTP host is required" unless settings["smtp_host"].length > 0
    errors << "SMTP port is required" unless settings["smtp_port"].length > 0
    errors << "SMTP user is required" unless settings["smtp_user"].length > 0
    errors << "SMTP password is required" unless settings["smtp_password"].length > 0
    errors << "SMTP authentication type is required" unless settings["smtp_auth"].length > 0
    errors << "SMTP domain type is required" unless settings["smtp_domain"].length > 0
    errors << "Categories are required" unless settings["categories"].length > 0
    errors << "Valid site email is required" unless settings["site_email"].length > 0 && settings["site_email"] =~ Regexp.new(Regexp::EMAIL)
    errors << "Valid administrator email is required" unless settings["administrator_email"].length > 0 && settings["administrator_email"] =~ Regexp.new(Regexp::EMAIL)
    errors << "User first name is required" unless settings["user"]["firstname"].length > 0
    errors << "User last name is required" unless settings["user"]["lastname"].length > 0
    errors << "User email address is required" unless settings["user"]["email"].length > 0 && settings["user"]["email"] =~ Regexp.new(Regexp::EMAIL)
    errors << "Password and password confirmation are required" unless settings["user"]["password"].length > 0 || settings["user"]["password_confirm"].length > 0
    errors << "Password and password confirmation must match" unless settings["user"]["password"] == settings["user"]["password_confirm"]
    return errors if errors.any?
    return :valid
  end
end