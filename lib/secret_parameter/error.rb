module SecretParameter
  
class AuthenticationError < StandardError
  def initialize msg
    super
  end
end
class DecryptionError < StandardError
  def initialize msg
    super
  end
end
class MessageError < StandardError
  def initialize msg
    super
  end
end
class PackerError < StandardError
  def initialize msg
    super
  end
end
class NonceError < StandardError
  def initialize msg
    super
  end
end

end