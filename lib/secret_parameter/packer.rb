require_relative 'error'

module SecretParameter
  class AbstractPacker
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def min_bytes
      num_bytes
    end

    def max_bytes
      num_bytes
    end

    def check_string(str)
      raise PackerError, "Expected string, got #{str.class.name}" unless str.is_a? String
      raise PackerError, "String too short, expected #{min_bytes}, got #{str.bytesize}" if (str.bytesize < min_bytes)
      raise PackerError, "String too long, expected #{max_bytes}, got #{str.bytesize}" if (!max_bytes.nil? && str.bytesize > max_bytes)
    end
  end

  class AbstractUintPacker < AbstractPacker
    def check_value(uint)
      raise PackerError, "Expected integer, got #{uint.class.name}" unless uint.is_a? Integer
      raise PackerError, "Expected non-negative integer, got #{uint}" if (uint < 0)

      exp = num_bytes * 8
      limit = 2 ** exp
      raise PackerError, "Expected integer below #{limit}, got #{uint}" if (uint >= limit)
    end

    def pack(value)
      check_value value
      [value].pack(directive)
    end

    def unpack(string)
      check_string string
      string.unpack(directive).first
    end
  end

  class Uint8Packer < AbstractUintPacker
    def directive
      'C'
    end

    def num_bytes
      1
    end
  end

  class Uint16Packer < AbstractUintPacker
    def directive
      'S<'
    end

    def num_bytes
      2
    end
  end

  class Uint32Packer < AbstractUintPacker
    def directive
      'L<'
    end

    def num_bytes
      4
    end
  end

  class Uint64Packer < AbstractUintPacker
    def directive
      'Q<'
    end

    def num_bytes
      8
    end
  end

  class StringPacker < AbstractPacker
    INFINITY = (2**(0.size * 8 -2) -1)
    def initialize(name, min_bytes = 0, max_bytes = INFINITY)
      raise PackerError, "Expected minimum to be non-negative, got #{min_bytes}" if min_bytes < 0
      raise PackerError, "Maximum can't be lower than minimum #{min_bytes}/#{max_bytes}" if max_bytes < min_bytes

      @min_bytes = min_bytes
      @max_bytes = max_bytes
      super name
    end
    
    def check_value(value)
      check_string value
    end

    def pack(value)
      check_value value
      value
    end

    def unpack(value)
      check_value value
      value
    end

    def min_bytes
      @min_bytes
    end

    def max_bytes
      @max_bytes
    end

    def num_bytes
      return nil unless min_bytes == max_bytes

      min_bytes
    end
  end
end
