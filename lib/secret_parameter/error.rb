module SecretParameter
  class Error < RuntimeError; end

  class Base64Error < Error; end 

  class AuthenticationError < Error; end

  class DecryptionError < Error; end

  class MessageError < Error; end

  class PackerError < Error; end

  class NonceError < Error; end
end