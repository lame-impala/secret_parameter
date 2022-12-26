require_relative 'test_helper'
require_relative '../lib/secret_parameter/key'

class KeyTest < Minitest::Test
  def test_salted_key_init_works
    key1 = SecretParameter::Key.new('SECRET', 'SALT')
    assert_equal(32, key1.to_s.length)
  end

  def test_num_iterations_makes_difference
    key1 = SecretParameter::Key.new('SECRET', 'SALT')
    key2 = SecretParameter::Key.new('SECRET', 'SALT', 999)
    refute_equal(key1, key2)
  end

  def test_salted_key_equality_check_works
    key1 = SecretParameter::Key.new('SECRET', 'SALT')
    key2 = SecretParameter::Key.new('SECRET', 'SALT')
    assert_equal(key1, key2)
    key3 = SecretParameter::Key.new('secret', 'SALT')
    refute_equal(key1, key3)
    key4 = SecretParameter::Key.new('SECRET', 'salt')
    refute_equal(key1, key4)
  end
end
