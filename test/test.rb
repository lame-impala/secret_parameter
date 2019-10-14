require 'simplecov'
SimpleCov.root "#{Dir.getwd}/.."
SimpleCov.start do
    add_filter %r{^/test/}
end

# require_relative 'abstract_message_test'
require_relative 'key_test'
require_relative 'packer_test'
require_relative 'message_test'
require_relative 'message_factory_builder_test'
require_relative 'nonce_test'
require_relative 'nonce_factory_builder_test'
require_relative 'secure_channel_test'
require_relative 'secret_parameter_test'
