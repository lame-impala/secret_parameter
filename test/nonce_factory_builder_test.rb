require_relative 'test_helper'
require_relative '../lib/secret_parameter/nonce_factory_builder.rb'

class NonceFactoryBuilderTest < Minitest::Test
  def test_nonce_building
    nb = SecretParameter::NonceFactoryBuilder.new
    nb.uint8
    nb.uint16
    nb.uint32
    nb.string 8
    nc = nb.build
    assert_equal(15, nc.num_bytes)
    nonce = nc.new 8, 16, 32, 'abcdefgh'
    assert_equal(15, nonce.pack.length)
  end
end