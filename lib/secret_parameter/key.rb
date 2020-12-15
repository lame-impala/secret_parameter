require 'openssl'

module SecretParameter
  class Key
    KEY_LEN = 32
    ITER = 20_000

    def initialize(key, salt, num_iterations = ITER)
      hashed = OpenSSL::Digest::SHA1.digest(salt)
      @key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(key, hashed, num_iterations, KEY_LEN)
    end

    def to_s
      @key
    end

    def ==(other)
      return false unless other.is_a? self.class

      to_s == other.to_s
    end
  end
end