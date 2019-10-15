# SecretParameter
### Ruby module for encrypting and decrypting query parameters

#### Message
Message follows a predefined template that is composed from numbers and strings. Strings must have fixed length, only the last part can be a variable length string. Unsigned numbers of various byte widths are accepted, signed numbers do not seem terribly useful for common use cases so they're not an option. A message template is defined like so:
```
message_factory = SecretParameter.message_factory_builder.new
  .uint8(:protocol)
  .uint64(:index)
  .string(:token, min_bytes: 4, max_bytes: 4)
  .string(:email)
  .build
message = message_factory.new protocol: 1, index: 642, token: 'abcd', email: 'email@example.com'
```
This piece of code creates a factory producing messages composed of 8 bit and 64 bit number, a fixed length string and a variable length string. A message instance is then constructed. The instance has reader methods on it for all defined fields, so its possible to query them directly: `email = message.email` (this is the reason why names of elementary Object methods like `:method` and `:send` are reserved and can't be used.)


#### Algorithm
All algorithms used here are well known, widely used cryptography primitives. This makes the concept portable easily to just any other platform outside Ruby, so that for example a .NET system can exchange messages with a system written in Ruby. 
Encryption algorithm used is AES-256 in CRT mode. The advantage of streaming mode over a block cipher is that a short message stays short even after being encrypted, while a block cipher would have to apply padding to fill one whole block. In the streaming mode it is necessary to ensure that every message is encrypted using a different, unique initialization vector. Reusing initialization vectors would compromise security of the whole system.

#### Nonce
Since the library itself has no means of producing series of nonces reliably, it is a responsibility of the client code to provide such numbers. If the system is stateless or no reliable persistent counter can be set up, system time may be an acceptable source of nonces in most cases. Since time is typically a 64 bit integer and the initialization vector is required to be 16 bytes long, such nonce would be extended by a series of 8 random bites, which makes it highly improbable that an instance of initialization vector will be repeated. 
Nonce template is created in a similar manner as the message template. The following code creates a nonce template composed of two 32 bit numbers, then creates an instance of such nonce and produces a 16 bytes long initialization vector, where the last 8 bytes are random: 
```
nonce_factory = SecretParameter::nonce_factory_builder
  .uint32
  .uint32
  .build
nonce = nonce_factory.new 4, 150
iv = nonce.iv
```

#### Secret parameter
After having defined a message factory and nonce factory, an instance of SecreteParameter can be created:
```
sp = SecretParameter::create(
  message_factory: mf, 
  nonce_factory: nf,
  cipher_key: "cipher key", 
  cipher_salt: "cipher salt", 
  auth_key: "authentication key", 
  auth_salt: "authentication salt"
)
```
Two key/salt pairs are needed here. They may be strings of arbitrary lengths for they are run through a key extension function with the salt mixed in in the process to obtain keys of required length. 

With SecretParameter object in hand it's now possible to actually perform encryption and decryption. Encrypted message, along with the initialization vector, is authenticated using HMAC tag that is attached to it. In the end, the whole is converted to Base64 encoding:
```
message = sp.create_message(protocol: 1, index: 642, token: "abcd", email: "email@example.com")
nonce = sp.create_nonce(35781)
cipher = sp.encrypt_tag_encode(message, nonce)
decrypted = sp.decode_authenticate_decrypt(cipher)
assert_equal(message, decrypted)
```
Authentication tag is by default 32 bytes long. In some cases this may make the message too long and unwieldy, so there's a possibility to truncate the tag down to certain size. This is done when defining the message factory: 
```
message_factory = SecretParameter.message_factory_builder.new
  .uint64(:index)
  .mac_length(16)
  .build
```
Naturally, HMAC truncated this way provides less security than full length one and should be used judiciously.

