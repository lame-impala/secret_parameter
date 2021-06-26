require 'minitest/autorun.rb'
require_relative '../lib/secret_parameter/secret_parameter.rb'
require_relative './test_helper.rb'


require 'byebug'

class SecretParameterTest < Minitest::Test
  def secret_parameter_setup
    mf = SecretParameter::message_factory_builder
      .uint16('index')
      .uint8('protocol')
      .string('email')
      .mac_length(8)
      .build
    nf = SecretParameter::nonce_factory_builder.uint64.build
    SecretParameter::create(
      message_factory: mf,
      nonce_factory: nf,
      cipher_key: 'cipher key',
      cipher_salt: 'cipher salt',
      auth_key: 'authentication key',
      auth_salt: 'authentication salt'
    )
  end

  def test_invalid_base64_raises_proprietary_error
    sp = secret_parameter_setup
    err = assert_raises(SecretParameter::Base64Error) do
      sp.decode_authenticate_decrypt('xyz')
    end
    assert_equal 'invalid base64', err.message
  end

  def test_secret_param_api_test
    sp = secret_parameter_setup
    message = sp.create_message(index: 10, protocol: 20, email: 'eml')
    nonce = sp.create_nonce(1)
    cipher = sp.encrypt_tag_encode(message, nonce)
    decrypted = sp.decode_authenticate_decrypt(cipher)
    assert_equal(message, decrypted)
  end
end