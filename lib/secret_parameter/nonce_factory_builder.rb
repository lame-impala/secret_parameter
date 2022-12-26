require_relative 'nonce'
require_relative 'error'

module SecretParameter
  class NonceFactoryBuilder
    def initialize
      @class = Class.new(Nonce)
    end

    def uint8
      @class.add_packer Uint8Packer.new(next_name)
      self
    end

    def uint16
      @class.add_packer Uint16Packer.new(next_name)
      self
    end

    def uint32
      @class.add_packer Uint32Packer.new(next_name)
      self
    end

    def uint64
      @class.add_packer Uint64Packer.new(next_name)
      self
    end

    def string(bytes)
      @class.add_packer StringPacker.new(next_name, bytes, bytes)
      self
    end

    def build
      raise NonceError, 'Nonce must not be empty' if @class.packers.empty?

      @class.freeze
    end

    private

    def next_name
      "part#{@class.packers.length}"
    end
  end
end