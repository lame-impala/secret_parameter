require_relative 'error'
require_relative 'packer'

module SecretParameter
  class Message
    def self.min_bytes
      @min_bytes ||= 0
    end

    def self.max_bytes
      @max_bytes ||= 0
    end

    def self.mac_length
      @mac_length ||= 32
    end

    def self.packers
      @packers ||= []
    end

    def initialize(**fields)
      extract_fields fields
    end

    def self.add_packer(packer)
      raise TypeError, 'Not a packer' unless packer.is_a? AbstractPacker
      if min_bytes < max_bytes
        raise MessageError, "Can't add after a variable length packer"
      end

      @min_bytes = min_bytes + packer.min_bytes
      @max_bytes = if packer.max_bytes == StringPacker::INFINITY
        StringPacker::INFINITY
      else
        packer.max_bytes + self.max_bytes
      end

      define_reader packer.name
      packers << packer
    end

    def self.define_reader(name)
      raise MessageError, "Reserved name: #{name}" if method_defined? name

      define_method name do
        instance_variable_get "@#{name}"
      end
    end

    def extract_fields(fields)
      fields = fields.dup
      self.class.packers.each do |packer|
        name = packer.name
        sym = name.to_sym
        if fields.has_key?(sym)
          value = fields[sym]
          packer.check_value value
          instance_variable_set("@#{name}", value)
          fields.delete(sym)
        else
          raise MessageError, "Missing field: #{name}"
        end
      end
      if fields.count.positive?
        raise MessageError, "Unknown fields: #{fields.keys.join(', ')}"
      end
    end

    def pack
      string = ''
      self.class.packers.each do |packer|
        value = send packer.name
        string += packer.pack value
      end
      string
    end

    def self.unpack(string)
      fields = {}
      start_idx = 0

      packers.each do |packer|
        raise MessageError, "Bad index: #{start_idx}" if (start_idx < 0)

        num_bytes = packer.num_bytes

        end_idx = if num_bytes.nil?
          -1
        else
          start_idx + num_bytes
        end

        substring = if end_idx >= 0
          string.byteslice(start_idx...end_idx)
        else
          string.byteslice(start_idx..end_idx)
        end

        fields[packer.name.to_sym] = packer.unpack(substring)
        start_idx = end_idx
      end
      new(**fields)
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      self.class.packers.all? do |packer|
        proper_val = send packer.name
        other_val = other.send packer.name
        proper_val == other_val
      end
    end
  end
end
