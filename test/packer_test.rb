require 'minitest/autorun.rb'
require '../lib/secret_parameter/packer.rb'
require './test_helper.rb'

class Uint8Test < Minitest::Test
  def test_uint8_accessors_work
    uint8 = SecretParameter::Uint8Packer.new('8_bit_unsigned_integer')
    assert_equal(1, uint8.min_bytes)
    assert_equal(1, uint8.max_bytes)
    assert_equal('8_bit_unsigned_integer', uint8.name)
  end
  def test_uint8_packs_and_unpacks_correctly
    uint8 = SecretParameter::Uint8Packer.new('test')
    uint = 0
    assert_equal(uint, uint8.unpack(uint8.pack(uint)))
    uint = 2**8 -1
    assert_equal(uint, uint8.unpack(uint8.pack(uint)))
  end
  def test_uint8_checks_limits_correctly
    uint8 = SecretParameter::Uint8Packer.new('test')
    uint = -1
    assert_raises do 
      uint8.pack(uint)
    end
    uint = 256
    assert_raises do 
      uint8.pack(uint)
    end
  end
  def test_uint8_checks_string_length_correctly
    uint8 = SecretParameter::Uint8Packer.new('test')
    s = ''
    assert_raises do
      uint8.unpack(s)
    end
    s = 'ab'
    assert_raises do
      uint8.unpack(s)
    end
  end
end

class Uint16Test < Minitest::Test
  def test_uint16_packs_and_unpacks_correctly
    uint16 = SecretParameter::Uint16Packer.new('test')
    uint = 0
    assert_equal(uint, uint16.unpack(uint16.pack(uint)))
    uint = 2**16 -1
    assert_equal(uint, uint16.unpack(uint16.pack(uint)))
  end
  def test_uint16_checks_limits_correctly
    uint16 = SecretParameter::Uint16Packer.new('test')
    uint = -1
    assert_raises do 
      uint16.pack(uint)
    end
    uint = 2**16
    assert_raises do 
      uint16.pack(uint)
    end
  end
  def test_uint16_checks_string_length_correctly
    uint16 = SecretParameter::Uint16Packer.new('test')
    s = 'a'
    assert_raises do
      uint16.unpack(s)
    end
    s = 'abc'
    assert_raises do
      uint16s.unpack(s)
    end
  end
end

class Uint32Test < Minitest::Test
  def test_uint32_packs_and_unpacks_correctly
    uint32 = SecretParameter::Uint32Packer.new('test')
    uint = 0
    assert_equal(uint, uint32.unpack(uint32.pack(uint)))
    uint = 2**32 -1
    assert_equal(uint, uint32.unpack(uint32.pack(uint)))
  end
  def test_uint32_checks_limits_correctly
    uint32 = SecretParameter::Uint32Packer.new('test')
    uint = -1
    assert_raises do 
      uint32.pack(uint)
    end
    uint = 2**32
    assert_raises do 
      uint32.pack(uint)
    end
  end
  def test_uint32_checks_string_length_correctly
    uint32 = SecretParameter::Uint32Packer.new('test')
    s = 'abc'
    assert_raises do
      uint32.unpack(s)
    end
    s = 'abcde'
    assert_raises do
      uint32.unpack(s)
    end
  end
end
class Uint64Test < Minitest::Test
  def test_uint64_packs_and_unpacks_correctly
    uint64 = SecretParameter::Uint64Packer.new('test')
    uint = 0
    assert_equal(uint, uint64.unpack(uint64.pack(uint)))
    uint = 2**64 -1
    assert_equal(uint, uint64.unpack(uint64.pack(uint)))
  end
  def test_uint64_checks_limits_correctly
    uint64 = SecretParameter::Uint64Packer.new('test')
    uint = -1
    assert_raises do 
      uint64.pack(uint)
    end
    uint = 2**64
    assert_raises do 
      uint64.pack(uint)
    end
  end
  def test_uint64_checks_string_length_correctly
    uint64 = SecretParameter::Uint64Packer.new('test')
    s = 'abcdefg'
    assert_raises do
      uint64.unpack(s)
    end
    s = 'abcdefghi'
    assert_raises do
      uint64.unpack(s)
    end
  end
end


class StringTest < Minitest::Test
  def test_unbounded_string_checks_limits_correctly
    string = SecretParameter::StringPacker.new('unbounded_string')
    assert_equal(0, string.min_bytes)
    assert_equal(SecretParameter::StringPacker::INFINITY, string.max_bytes)
    assert_nil(string.num_bytes)
    assert_equal('unbounded_string', string.name)
    assert_equal('', string.unpack(string.pack('')))
  end
  
  def test_low_bounded_string_checks_limits_correctly
    string = SecretParameter::StringPacker.new('low_bounded_string', 6)
    assert_equal(6, string.min_bytes)
    assert_equal(SecretParameter::StringPacker::INFINITY, string.max_bytes)
    assert_nil(string.num_bytes)
    assert_equal('low_bounded_string', string.name)
    assert_equal('abcdef', string.unpack(string.pack('abcdef')))
    assert_raises do 
      string.pack('abcde')
    end
    assert_raises do
      string.unpack('abcde')
    end
  end
    
  def test_bounded_string_checks_limits_correctly
    string = SecretParameter::StringPacker.new('bounded_string', 2, 4)
    assert_equal(2, string.min_bytes)
    assert_equal(4, string.max_bytes)
    assert_nil(string.num_bytes)
    assert_equal('bounded_string', string.name)
    assert_equal('ab', string.unpack(string.pack('ab')))
    assert_equal('abcd', string.unpack(string.pack('abcd')))
    assert_raises do 
      string.pack('a')
    end
    assert_raises do
      string.unpack('a')
    end
    assert_raises do 
      string.pack('abcde')
    end
    assert_raises do
      string.unpack('abcde')
    end
  end
  def test_tightly_bounded_string_yields_num_bytes
    string = SecretParameter::StringPacker.new('bounded_string', 4, 4)
    assert_equal(4, string.min_bytes)
    assert_equal(4, string.max_bytes)
    assert_equal(4, string.num_bytes)
  end
end
