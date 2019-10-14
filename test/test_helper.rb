require '../lib/secret_parameter/message_factory_builder.rb'
require '../lib/secret_parameter/nonce_factory_builder.rb'

SignInMessage = SecretParameter::MessageFactoryBuilder.new
  .uint32(:index)
  .string(:email)
  .build

UnsubscribeMessage = SecretParameter::MessageFactoryBuilder.new
  .uint64(:index)
  .uint32(:service)
  .mac_length(8)
  .build
  
Uint32Nonce = SecretParameter::NonceFactoryBuilder.new.uint32.build
