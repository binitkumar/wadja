ActionMailer::Base.smtp_settings = {
    :address => 'smtp.sendgrid.net',
    :port => '25',
    :domain => 'example.com',
    :authentication => :plain,
    :user_name => 'wadjaapi',
    :password => 'w@90=Pas',
    :enable_starttls_auto => true
}