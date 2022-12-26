require_relative 'test_classes'
require_relative '../lib/secret_parameter/secure_channel.rb'

class SecureChannelTest < Minitest::Test
  def get_channel factory
    ec = SecretParameter::Key.new('encryption_key', 'salt1')
    ac = SecretParameter::Key.new('authentication_key', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, factory, nf)
    sc
  end

  def encryption_decryption_test(channel, msg)
    nonce = channel.nonce_factory.new(1)
    cipher = channel.encrypt_and_tag msg, nonce
    received = channel.authenticate_and_decrypt cipher

    assert_equal(msg, received)
  end

  def test_channel_works_with_sign_up_message
    sc = get_channel SignInMessage
    encryption_decryption_test(sc, SignInMessage.new(index: 1, email: ''))
    encryption_decryption_test(sc, SignInMessage.new(index: 209, email: 'email@example.com'))
    # Nor channel neither the message class is responsible for validating the contents
    encryption_decryption_test(sc, SignInMessage.new(
      index: 68,
      email: 'very.long.stretched.bogus.email.with.áčćěňťš.and.extra.whitespace.at@the.end      ')
    )
  end

  def test_mac_length_makes_difference
    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)
    msg = SignInMessage.new(index: 50, email: 'eml')
    enc = sc.encrypt_and_tag(msg, sc.nonce_factory.new(2))
    assert_equal(55, enc.length)

    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, UnsubscribeMessage, nf)
    msg = UnsubscribeMessage.new(index: 50, service: 150)
    enc = sc.encrypt_and_tag(msg, sc.nonce_factory.new(2))
    assert_equal(36, enc.length)
  end

  def test_wrong_message_class_raises
    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)
    msg = UnsubscribeMessage.new(index: 50, service: 20)
    exc = assert_raises do
      enc = sc.encrypt_and_tag(msg, sc.nonce_factory.new(2))
    end
    assert_equal('Wrong message class', exc.message)
  end

  def test_wrong_nonce_class_raises
    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)
    msg = SignInMessage.new(index: 50, email: 'eml')
    other_nonce_factory = SecretParameter::NonceFactoryBuilder.new.uint32.build
    exc = assert_raises(SecretParameter::MessageError) do
      sc.encrypt_and_tag(msg, other_nonce_factory.new(2))
    end
    assert_equal('Wrong nonce class', exc.message)
  end

  def test_channel_works_with_unsubscribe_message
    sc = get_channel UnsubscribeMessage
    encryption_decryption_test(sc, UnsubscribeMessage.new(index: 515, service: 150))
  end

  def test_auth_key_makes_difference
    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)
    msg = SignInMessage.new(index: 20, email: 'msg')
    enc = sc.encrypt_and_tag(msg, sc.nonce_factory.new(1))
    ac = SecretParameter::Key.new('ac2', 'salt2')
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)

    exc = assert_raises(SecretParameter::AuthenticationError) do
      sc.authenticate_and_decrypt(enc)
    end
    exp = 'Authentication failed:'
    assert_equal(
      exp,
      exc.message[0, exp.length]
    )
  end

  def test_auth_salt_makes_difference
    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nf = SecretParameter::NonceFactoryBuilder.new.uint32.build
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)
    msg = SignInMessage.new(index: 50, email: 'msg')
    enc = sc.encrypt_and_tag(msg, sc.nonce_factory.new(2))

    ac = SecretParameter::Key.new('ac1', 'salt3')
    sc = SecretParameter::SecureChannel.new(ec, ac, SignInMessage, nf)

    exc = assert_raises(SecretParameter::AuthenticationError) do
      sc.authenticate_and_decrypt(enc)
    end
    exp = 'Authentication failed:'
    assert_equal(
      exp,
      exc.message[0, exp.length]
    )
  end

  def test_empty_message_fails
    ec = SecretParameter::Key.new('ec1', 'salt1')
    ac = SecretParameter::Key.new('ac1', 'salt2')
    nc = SecretParameter::NonceFactoryBuilder.new.uint32.build
    exc = assert_raises(SecretParameter::MessageError) do
      SecretParameter.message_factory_builder.build
    end
    assert_equal('Message must not be empty', exc.message)
    mf = Class.new(SecretParameter::Message)
    sc = SecretParameter::SecureChannel.new(ec, ac, mf, nc)
    msg = mf.new
    exc = assert_raises(ArgumentError) do
      sc.encrypt_and_tag(msg, sc.nonce_factory.new(2))
    end
    assert_equal('data must not be empty', exc.message)
  end

  def test_empty_nonce_fails
    exc = assert_raises(SecretParameter::NonceError) do
      SecretParameter::NonceFactoryBuilder.new.build
    end
    assert_equal('Nonce must not be empty', exc.message)
  end
end
