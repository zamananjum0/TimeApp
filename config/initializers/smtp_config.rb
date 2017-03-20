ActionMailer::Base.smtp_settings = {
    address:   ENV['TIME_SMTP_ADDRESS_' + ENV['TIME_MODE']],
    domain:    ENV['TIME_SMTP_DOMAIN_' + ENV['TIME_MODE']],
    user_name: ENV['TIME_SMTP_USERNAME_' + ENV['TIME_MODE']],
    password:  ENV['TIME_SMTP_PASSWORD_' + ENV['TIME_MODE']],
    :port => 25,
    :authentication => :plain,
    :enable_starttls_auto => true
}