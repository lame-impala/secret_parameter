require 'minitest/autorun.rb'
require_relative '../lib/secret_parameter/message.rb'

class MessageTest < Minitest::Test
  def get_message_class
    message_class = Class.new(SecretParameter::Message)
    message_class.add_packer SecretParameter::Uint8Packer.new('uint8_field')
    message_class.add_packer SecretParameter::StringPacker.new('string_field')
    message_class    
  end

  def test_two_packers_can_not_have_same_name
    mc = Class.new(SecretParameter::Message)
    mc.add_packer SecretParameter::Uint8Packer.new('same_name')
    exc = assert_raises do
      mc.add_packer SecretParameter::Uint16Packer.new('same_name')
    end
    assert_equal('Reserved name: same_name', exc.message)
  end

  def test_message_construction
    mc = get_message_class
    m = mc.new(uint8_field: 4, string_field: 'Hello world')
    assert_equal(4, m.uint8_field)
    assert_equal('Hello world', m.string_field)
  end

  def test_message_constructor_fails_with_incorrect_parameters
    mc = get_message_class
    exc = assert_raises(SecretParameter::MessageError) do
      mc.new(uint8_field: 5)
    end
    assert_equal('Missing field: string_field', exc.message)
    exc = assert_raises(SecretParameter::MessageError) do
      mc.new(uint8_field: 5, string_field: 'abc', other: 1, another: 2)
    end
    assert_equal('Unknown fields: other, another', exc.message)
  end

  def test_reserved_name_cannot_be_taken
    mc = Class.new(SecretParameter::Message)
    exc = assert_raises(SecretParameter::MessageError) do
      mc.define_reader :method
    end
    assert_equal('Reserved name: method', exc.message)
  end

  def test_values_are_checked
    mc8 = Class.new(SecretParameter::Message)
    mc8.add_packer SecretParameter::Uint8Packer.new('uint8')
    exc = assert_raises(SecretParameter::PackerError) do
      mc8.new uint8: -1
    end
    assert_equal('Expected non-negative integer, got -1', exc.message)
    
    mcs = Class.new(SecretParameter::Message)
    mcs.add_packer SecretParameter::StringPacker.new('string', 4, 4)
    exc = assert_raises do
      mcs.new string: 'zcr'
    end
    assert_equal('String too short, expected 4, got 3', exc.message)
    exc = assert_raises do
      mcs.new string: 'žčř'
    end
    assert_equal('String too long, expected 4, got 6', exc.message)
  end

  def test_min_max_bytes_work
    mc24 = Class.new(SecretParameter::Message)
    assert_equal(0, mc24.min_bytes)
    assert_equal(0, mc24.max_bytes)
    mc24.add_packer SecretParameter::Uint8Packer.new('uint8')
    assert_equal(1, mc24.min_bytes)
    assert_equal(1, mc24.max_bytes)
    mc24.add_packer SecretParameter::Uint16Packer.new('uint16')
    assert_equal(3, mc24.min_bytes)
    assert_equal(3, mc24.max_bytes)

    mcs = Class.new(SecretParameter::Message)
    assert_equal(0, mcs.min_bytes)
    assert_equal(0, mcs.max_bytes)
    mcs.add_packer SecretParameter::Uint8Packer.new('uint8a')
    assert_equal(1, mcs.min_bytes)
    assert_equal(1, mcs.max_bytes)
    mcs.add_packer SecretParameter::Uint8Packer.new('uint8b')
    assert_equal(2, mcs.min_bytes)
    assert_equal(2, mcs.max_bytes)
    mcs.add_packer SecretParameter::StringPacker.new('string')
    assert_equal(2, mcs.min_bytes)
    assert_equal(SecretParameter::StringPacker::INFINITY, mcs.max_bytes)
  end

  def test_variable_length_packer_must_be_the_last
    mc = Class.new(SecretParameter::Message)
    mc.add_packer SecretParameter::StringPacker.new('string0', 4, 4)
    mc.add_packer SecretParameter::StringPacker.new('string1', 4, 6)
    exc = assert_raises do
      mc.add_packer SecretParameter::StringPacker.new('string2', 4)
    end
    assert_equal("Can't add after a variable length packer", exc.message)
  end

  def test_unbouded_length_packer_must_be_the_last
    mc = Class.new(SecretParameter::Message)
    mc.add_packer SecretParameter::StringPacker.new('string0', 4, 4)
    mc.add_packer SecretParameter::StringPacker.new('string1', 4)
    exc = assert_raises do
      mc.add_packer SecretParameter::StringPacker.new('string2', 4)
    end
    assert_equal("Can't add after a variable length packer", exc.message)
  end
  def test_equality_works
    mc0 = Class.new(SecretParameter::Message)
    mc0.add_packer SecretParameter::Uint8Packer.new('uint8a')
    mc0.add_packer SecretParameter::Uint8Packer.new('uint8b')
    
    mc1 = Class.new(SecretParameter::Message)
    mc1.add_packer SecretParameter::Uint8Packer.new('uint8a')
    mc1.add_packer SecretParameter::Uint8Packer.new('uint8b')
    
    m00 = mc0.new(uint8a: 1, uint8b: 2)
    m01 = mc0.new(uint8a: 1, uint8b: 2)
    assert_equal(m00, m01)    
    m02 = mc0.new(uint8a: 2, uint8b: 2)
    refute_equal(m00, m02)
    m03 = mc0.new(uint8a: 1, uint8b: 1)
    refute_equal(m00, m03)    
    
    m04 = mc1.new(uint8a: 1, uint8b: 2)
    refute_equal(m00, m04)
  end

  def test_packing_and_unpacking_works
    mc = Class.new(SecretParameter::Message)
    mc.add_packer SecretParameter::Uint8Packer.new('uint8')
    mc.add_packer SecretParameter::Uint16Packer.new('uint16')
    mc.add_packer SecretParameter::Uint32Packer.new('uint32')
    mc.add_packer SecretParameter::Uint64Packer.new('uint64')
    mc.add_packer SecretParameter::StringPacker.new('string4', 4, 4)
    mc.add_packer SecretParameter::StringPacker.new('string')
    m = mc.new(uint8: 1, uint16: 2, uint32: 3, uint64: 4, string4: 'abdc', string: 'string')
    packed = m.pack
    assert_equal(25, packed.bytesize)
    unpacked = mc.unpack(packed)
    assert_equal(unpacked, m)
  end
end

