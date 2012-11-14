include SendGrid
class Mailer < ActionMailer::Base
  default :from => 'no-reply@example.com',
          :subject => 'An email sent via SendGrid'

  def email_with_multiple_recipients
    mail :to => %w(email1@email.com email2@email.com)
  end

  def forgot_username_password
    mail :to => "bintech06@gmail.com"
  end
end