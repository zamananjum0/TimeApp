class UserMailer < ApplicationMailer
  def registration_confirmation(email)
    @email            = email
    @activation_token = User.find_by_email(email).authentication_token
    url               = ENV['TIME_DOMAIN_' + ENV['TIME_MODE']]
    @activation_link  = '<a href="http://{{URL}}/users/activation?authentication_token={{ACTIVATION_TOKEN}}">Confirm you registration</a>'
    
    @activation_link = @activation_link.gsub("{{ACTIVATION_TOKEN}}", @activation_token)
    @activation_link = @activation_link.gsub("{{URL}}", url)
    
    mail(to: @email, subject: 'Registration Confirmation', from: 'info@time.com')
  end
end
