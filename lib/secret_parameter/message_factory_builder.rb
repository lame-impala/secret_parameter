require_relative 'error'
require_relative 'message'

module SecretParameter
  class MessageFactoryBuilder
    def initialize
      @class = Class.new(Message)
    end

    def mac_length(val)
      raise MessageError, "MAC length expected in range from 8 to 32 bytes, got #{val}" if val < 8 || val > 32

      @class.instance_variable_set :@mac_length, val
      self
    end

    def uint8(name)
      @class.add_packer Uint8Packer.new(name)
      self
    end

    def uint16(name)
      @class.add_packer Uint16Packer.new(name)
      self
    end

    def uint32(name)
      @class.add_packer Uint32Packer.new(name)
      self
    end

    def uint64(name)
      @class.add_packer Uint64Packer.new(name)
      self
    end

    def string(name, min_bytes: 0, max_bytes: StringPacker::INFINITY)
      @class.add_packer StringPacker.new(name, min_bytes, max_bytes)
      self
    end

    def build
      raise MessageError, 'Message must not be empty' if @class.packers.empty?

      @class.freeze
    end
  end
end