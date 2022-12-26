require_relative 'test_helper'
require_relative '../lib/secret_parameter/message_factory_builder.rb'

class MessageFactoryBuilderTest < Minitest::Test 
  def test_message_building 
    factory = SecretParameter::MessageFactoryBuilder
      .new
      .uint8('first')
      .uint16('second')
      .uint32('third')
      .string('bounded', min_bytes: 4, max_bytes: 4)
      .string('unbounded')
      .mac_length(8)
      .build
    assert_equal(5, factory.packers.length)
    assert_equal(11, factory.min_bytes)
    assert_equal(SecretParameter::StringPacker::INFINITY, factory.max_bytes)
    assert_equal(8, factory.mac_length)
    msg = factory.new first: 1, second: 2, third: 3, bounded: 'abcd', unbounded: 'string'
    assert_equal(1, msg.first)
    assert_equal(2, msg.second)
    assert_equal(3, msg.third)
    assert_equal('abcd', msg.bounded)
    assert_equal('string', msg.unbounded)
  end
end