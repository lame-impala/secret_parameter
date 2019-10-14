require_relative 'error'

module SecretParameter

class SecureChannel
  IV_LENGTH = 16
  attr_reader :message_factory, :nonce_factory
  def initialize (cipher_key, auth_key, message_factory, nonce_factory)
    @cipher_key = cipher_key
    @auth_key = auth_key
    @message_factory = message_factory
    @nonce_factory = nonce_factory
  end
  
  def encrypt_and_tag(message, nonce)
    raise MessageError.new("Wrong message class") unless self.message_factory === message
    raise MessageError.new("Wrong nonce class") unless self.nonce_factory === nonce
    iv = nonce.iv
    plain = message.pack
    cipher = encrypt(plain, iv)
    tag = calculate_mac(cipher)
    return iv + cipher + tag
  end
  
  def authenticate_and_decrypt(full_message)
    iv = full_message.byteslice(0...IV_LENGTH)
    if iv.nil? || iv.length < IV_LENGTH
      raise DecryptionError.new("IV too short: '#{hex(iv)}'")
    end
    mac = full_message.byteslice(-mac_length..-1)
    if mac.nil? || mac.length < mac_length
      raise AuthenticationError("HMAC too short: '#{hex(tag)}'")
    end
    ciphertext = full_message.byteslice(IV_LENGTH...-mac_length)
    if ciphertext.nil? || ciphertext.length < message_factory.min_bytes
      raise DecryptionError.new("Ciphertext too short: '#{hex(ciphertext)}'")
    end
    expected = calculate_mac(ciphertext)
    if expected != mac
      raise AuthenticationError.new("Authentication failed: #{hex(mac)} != #{hex(expected)}")      
    end
    plaintext = decrypt(ciphertext, iv).force_encoding("UTF-8")
    message_factory.unpack(plaintext)
  end
  
  private
  attr_reader :cipher_key, :auth_key
  def mac_length
    message_factory.mac_length
  end
  
  def calculate_mac(data)
    key = auth_key.to_s
    raise RuntimeError("Authentication key not initialized properly") if key.empty?
    digest = OpenSSL::Digest.new('sha256')
    mac = OpenSSL::HMAC.digest(digest, key, data)
    return mac.byteslice(0...mac_length)
  end
    
  def encrypt(plaintext, iv)
    aes = get_aes :encrypt
    aes.iv = iv
    ciphertext = aes.update(plaintext)
    return ciphertext
  end
  
  def decrypt(ciphertext, iv)
    aes = get_aes :decrypt
    aes.iv = iv
    plaintext = aes.update(ciphertext)
    return plaintext
  end
  
  def get_aes(method)
    aes = OpenSSL::Cipher::Cipher.new('aes-256-ctr').send(method);
    key = cipher_key.to_s
    raise RuntimeError("Cipher key not initialized properly") if key.empty?
    aes.key = key;
    return aes;
  end
  
  def hex string
    hex = string.to_s.each_byte.map {|b| b.to_s(16)}.join
  end
end

end