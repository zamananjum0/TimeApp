ActionMailer::Base.smtp_settings = {
    address:   ENV['MARVEL_SMTP_ADDRESS_' + ENV['MARVEL_MODE']],
    domain:    ENV['MARVEL_SMTP_DOMAIN_' + ENV['MARVEL_MODE']],
    user_name: ENV['MARVEL_SMTP_USERNAME_' + ENV['MARVEL_MODE']],
    password:  ENV['MARVEL_SMTP_PASSWORD_' + ENV['MARVEL_MODE']],
    :port => 25,
    :authentication => :plain,
    :enable_starttls_auto => true
}