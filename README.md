# SecretParameter
### Ruby module for encrypting and decrypting query parameters

#### Message
Each message follows a predefined structure. Parts of it might be numbers or fixed length strings, while the last part might be a variable length string. So far unsigned numbers of various byte lengths are accepted. While allowing signed numbers would pose no problem, they do not seem terribly useful for common use cases, so they are not yet implemented. A message template is defined like so:
```
message_factory = SecretParameter.message_factory_builder.new
  .uint8(:protocol)
  .uint64(:index)
  .string(:token, min_bytes: 8, max_bytes: 8)
  .string(:email)
  .build
message = message_factory.new protocol: 1, index: 642, token: 'abcd', email: 'email@example.com'
```
Previous piece of code creates a factory producing messages composed from one 8 bit and 64 bit numbers, one fixed length string and one variable length string. A message instance is then constructed. The instance has reader methods on it for all defined fields, so its possible to query them directly:

```message.string```

This is the reason why inherent Object method names (eg. :method and :send) are reserved and can't be used


#### Encryption algorithm
Algorithm used is AES-256 in CRT mode. The advantage of streaming mode over a block cipher is that a short message stays short even after being encrypted, while a block cipher would have to apply padding to fill one whole block. In the straming mode it is necessary to ensure that every message is encrypted using a different, unique initialization vector. Reusing initialization vectors would compromise security of the whole system.

#### Nonce
Since the library itself has no means of producing reliably series of unique numbers, it is a responsibility of the client code to provide such numbers. If a persistent counter can't be set up, system time may be an acceptable source of nonces in most cases. Since time is typically a 64 bit integer and the initialization vector needs to be 16 bytes long, the nonce would be extended by a series of 8 random bites, which makes it highly improbable that an instance of initialization vector will be repeated. 
Nonce template is created in a similar manner as the message template. The following code created a nonce template composed of two 32 bit numbers, then creates an instance of such nonce and produces a 16 bytes long initialization vector, where the last 8 bytes are random: 

```
nonce_factory = SecretParameter::nonce_factory_builder
  .uint32
  .uint32
  .build
nonce = nonce_factory.new 4, 150
iv = nonce.iv
```



The task is easier in that those numbers must not be random. Database may be a good source of such series of numbers. The initialization vector passed to the AES is required to be of length of 16 bytes while

#### Authentication
Both encrypted message and the initialization vector

#### Keys

