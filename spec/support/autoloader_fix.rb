# Fix for Rails 8 autoloader issues in test environment
# This prevents the FrozenError when modifying autoloader paths

Rails.application.config.autoloader = :zeitwerk if defined?(Zeitwerk)
