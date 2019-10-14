require_relative "packer"
require_relative 'error'
require 'securerandom'

module SecretParameter

class Nonce
  IV_LENGTH = 16
  def self.num_bytes
     self.packers.reduce(0) do |acc, packer|
       acc + packer.num_bytes
     end
  end
  def self.packers
    @packers = [] if @packers.nil?
    @packers
  end

  def initialize *fields
    check_fields fields
    @fields = fields.dup
  end
  def self.add_packer packer
    raise TypeError.new("Not a packer") unless packer.is_a? AbstractPacker
    raise NonceError.new("Packer must have definite length") if packer.num_bytes.nil?
    if self.num_bytes + packer.num_bytes > IV_LENGTH
      raise NonceError.new("Can't add packer, nonce too long")
    end
    packers << packer
  end
  def check_fields fields
    if self.class.packers.length != fields.length
      raise NonceError.new("Expected #{self.class.packers.length} parameters, got #{fields.length}")
    end
    self.class.packers.each_with_index do |packer, index|
      value = fields[index]
      packer.check_value value      
    end    
  end
  def pack
    string = ""
    self.class.packers.each_with_index do |packer, index|
      value = @fields[index]
      string += packer.pack value
    end
    string
  end
  def iv
    bytes_missing = IV_LENGTH - self.class.num_bytes
    return self.pack if (bytes_missing < 1)
    return self.pack + SecureRandom.random_bytes(bytes_missing)
  end
end

end