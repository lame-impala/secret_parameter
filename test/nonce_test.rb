require 'minitest/autorun.rb'
require_relative '../lib/secret_parameter/nonce.rb'

class NonceTest < Minitest::Test
  def test_nonce_creation
    nc = Class.new(SecretParameter::Nonce)
    assert_equal(0, nc.num_bytes)
    nc.add_packer(SecretParameter::Uint8Packer.new('0'))
    assert_equal(1, nc.num_bytes)
    nc.add_packer(SecretParameter::Uint16Packer.new('1'))
    assert_equal(3, nc.num_bytes)
    nc.add_packer(SecretParameter::Uint32Packer.new('2'))
    assert_equal(7, nc.num_bytes)
    nc.add_packer(SecretParameter::Uint64Packer.new('4'))
    assert_equal(15, nc.num_bytes)

    exc = assert_raises(SecretParameter::NonceError) do
      nc.add_packer(SecretParameter::Uint64Packer.new('4'))
    end
    assert_equal("Can't add packer, nonce too long", exc.message)
  end

  def test_nonce_packing
    nc = Class.new(SecretParameter::Nonce)
    nc.add_packer(SecretParameter::Uint8Packer.new('0'))
    nc.add_packer(SecretParameter::Uint16Packer.new('1'))
    nonce = nc.new(102, 105)
    packed = nonce.pack
    assert_equal(3, packed.length)
    exc = assert_raises(SecretParameter::NonceError) do
      nc.new(100)
    end
    assert_equal('Expected 2 parameters, got 1', exc.message)

    exc = assert_raises(SecretParameter::PackerError) do
      nc.new(256, 105)
    end
    assert_equal('Expected integer below 256, got 256', exc.message)
  end

  def test_nonce_padding
    nc = Class.new(SecretParameter::Nonce)
    nc.add_packer(SecretParameter::Uint8Packer.new('0'))
    nc.add_packer(SecretParameter::Uint16Packer.new('1'))
    nonce = nc.new(102, 105)
    iv = nonce.iv
    assert_equal(16, iv.length)
  end
end