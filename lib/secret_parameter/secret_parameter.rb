require 'base64'
require_relative "secure_channel"
require_relative "message_factory_builder"
require_relative "nonce_factory_builder"
require_relative 'key'

module SecretParameter
  def self.message_factory_builder
    MessageFactoryBuilder.new
  end

  def self.nonce_factory_builder
    NonceFactoryBuilder.new
  end

  def self.create(**opts)
    SecretParameter.new **opts
  end

  class SecretParameter
    attr_reader :channel
    def initialize(message_factory:, nonce_factory:, cipher_key:, cipher_salt:, auth_key:, auth_salt:)
      ck = Key.new(cipher_key, cipher_salt)
      ak = Key.new(auth_key, auth_salt)
      @channel = SecureChannel.new(ck, ak, message_factory, nonce_factory)
    end

    def encrypt_tag_encode(message, nonce)
      encrypted = channel.encrypt_and_tag(message, nonce)
      Base64.urlsafe_encode64(encrypted)
    end

    def decode_authenticate_decrypt(encoded)
      padded = self.class.pad(encoded)
      decoded = Base64.urlsafe_decode64(padded)
      channel.authenticate_and_decrypt(decoded)
    end

    def self.pad(string)
      length = string.length
      mod = length % 4
      length += (4 - mod) if mod > 0
      string.ljust(length, '=')
    end

    def create_message(**opts)
      @channel.message_factory.new **opts
    end

    def create_nonce(*args)
      @channel.nonce_factory.new *args
    end
  end
end