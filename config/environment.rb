# Load the Rails application.
require_relative "application"

APP_VERSION = `git describe --always`.sub(/.*-g/, '') unless defined? APP_VERSION

# Initialize the Rails application.
Rails.application.initialize!
