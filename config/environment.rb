# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.sendgrid.net',
    :port => '25',
    :domain => 'wadja.com',
    :authentication => :plain,
    :user_name => 'wadjaapi',
    :password => 'w@90=Pas',
    :enable_starttls_auto => true
}
# Initialize the rails application
Wadja::Application.initialize!
