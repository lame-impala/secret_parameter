module SecretParameter
  class AuthenticationError < StandardError; end

  class DecryptionError < StandardError; end

  class MessageError < StandardError; end

  class PackerError < StandardError; end

  class NonceError < StandardError; end
end