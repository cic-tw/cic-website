Recaptcha.configure do |config|
  config.site_key  = Setting.recaptcha.public_key
  config.public_key  = Setting.recaptcha.public_key
  config.secret_key = Setting.recaptcha.private_key
  config.private_key = Setting.recaptcha.private_key
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end