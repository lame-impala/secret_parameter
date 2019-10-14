require_relative 'error'
require_relative 'packer'

module SecretParameter

class Message
  class << self
    attr_reader :max_bytes
  end
  def self.min_bytes
     @min_bytes = 0 if @min_bytes.nil?
     @min_bytes
  end
  def self.max_bytes
     @max_bytes = 0 if @max_bytes.nil?
     @max_bytes
  end
  def self.mac_length
     @mac_length = 32 if @mac_length.nil?
     @mac_length     
  end
  def self.packers
    @packers = [] if @packers.nil?
    @packers
  end
  def initialize **fields
    self.extract_fields fields
  end
  def self.add_packer packer
    raise TypeError.new("Not a packer") unless packer.is_a? AbstractPacker
    if self.max_bytes == StringPacker::INFINITY
      raise MessageError.new("Can't add after a variable length packer")
    end
    @min_bytes = min_bytes + packer.min_bytes
    @max_bytes = unless packer.max_bytes == StringPacker::INFINITY
      packer.max_bytes + self.max_bytes
    else
      StringPacker::INFINITY
    end
    define_reader packer.name
    packers << packer
  end
  def self.define_reader name
    raise RuntimeError.new("Reserved name: #{name}") if method_defined? name
    define_method name do
      instance_variable_get "@#{name}"
    end
  end
  def extract_fields fields
    fields = fields.dup
    checked = {}
    self.class.packers.each do |packer|
      name = packer.name
      sym = name.to_sym
      if fields.has_key?(sym)
        value = fields[sym]
        packer.check_value value
        instance_variable_set("@#{name}", value)
        fields.delete(sym)
      else
        raise MessageError.new("Missing field: #{name}")
      end
    end
    if fields.count > 0
      raise MessageError.new("Unknown fields: #{fields.keys.join(", ")}")
    end
  end
    
  def pack
    string = ""
    self.class.packers.each do |packer|
      value = self.send packer.name
      string += packer.pack value
    end
    string
  end
  
  def self.unpack string
    fields = {}
    start_idx = 0
    self.packers.each do |packer|
      raise MessageError.new("Bad index: #{start_idx}") if (start_idx < 0)
      num_bytes = packer.num_bytes
      end_idx = unless num_bytes.nil?
        start_idx + num_bytes
      else
        -1
      end
      substring = if end_idx >= 0
        string.byteslice(start_idx...end_idx)
      else 
        string.byteslice(start_idx..end_idx)
      end
      fields[packer.name.to_sym] = packer.unpack(substring)
      start_idx = end_idx
    end
    new **fields
  end
  def == other
    return false unless self.class === other
    self.class.packers.all? do |packer|
      proper_val = self.send packer.name
      other_val = other.send packer.name
      proper_val == other_val
    end    
  end
end

end
