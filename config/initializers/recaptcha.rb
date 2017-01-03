Recaptcha.configure do |config|
  config.site_key  = Setting.recaptcha.site_key
  config.secret_key = Setting.recaptcha.secret_key
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end