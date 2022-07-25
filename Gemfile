########  Default Rails 6 Gemfile Gems  #######
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6'

# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
#gem 'webpacker', '~> 5.0'
# using sprockets instead of webpacker
gem 'sprockets'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'coffee-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
########  END Default Rails 6 Gemfile Gems  #######

gem 'mysql2'
# handles conversion of edtf text strings into date objects
gem 'edtf', '>= 3.0.5'
gem 'edtf-humanize', '>= 1.0.0'
# policy manager for controlling user access based on controller/action
gem 'pundit', '>= 0.2.1'
# handle ADS group lookup through LDAP
gem 'ldap_groups_lookup'
# handles pagination
gem 'pagy'

# gems for connecting over ssh
gem 'net-scp'
gem 'net-ssh'
gem 'net-smtp'

# managed through yarn now
# gem 'sweetalert2'
# Use jquery as the JavaScript library
# gem 'jquery-rails', '>= 4.1.1'
# jquery UI asset pipeline
# gem 'jquery-ui-rails'

# gem for utilizing the solr server
gem 'sunspot_rails'
gem 'sunspot_solr'
# progress bar for sunspot rake tasks (like reindexing...)
gem 'progress_bar'

# gems that provide ability to queue a task to be run as an external process
gem 'delayed_job'
gem 'delayed_job_active_record'
gem "daemons"
# provides functionality for the above to "recur"
gem 'delayed_job_recurring'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# jquery UI asset pipeline
gem 'jquery-ui-rails'

# this gem hasn't been updated since 2018... it bundles sweet alert 2, but an older version 9.x. I think... when checking
# the sweet alert documentation make sure to look at older versions
gem 'sweetalert2'

gem "nested_form"










group :development, :local, :test, :local_p do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development, :local, :local_p do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'net-smtp', require: false
  gem 'net-imap', require: false
  gem 'net-pop', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
