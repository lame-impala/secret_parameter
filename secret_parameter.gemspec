Gem::Specification.new do |s|
  s.name        = 'secret_parameter'
  s.version     = '0.1.0'
  s.date        = '2019-10-14'
  s.summary     = "Module for secure communication using secret http parameter or URL"\
  s.description = "Wrapper over standard encryption primitives providing convenience methods "\
                  "to establish secure communication channel using http query parameter or a part of URL. "\
                  "Messages are encrypted using AES-256 CRT mode, authenticated using HMAC and finally "\
                  "the encrypted message is encoded Base64 encoded for use in the URL"
  s.authors     = ["lame-impala"]
  s.licenses    = ['MIT']
  s.homepage    = "https://github.com/lame-impala/secret_parameter"
  s.email       = 'workerman@seznam.cz'
  s.files       = ["lib/secret_parameter.rb", 
                   "lib/secret_parameter/error.rb", 
                   "lib/secret_parameter/key.rb", 
                   "lib/secret_parameter/message_factory_builder.rb", 
                   "lib/secret_parameter/message.rb",
                   "lib/secret_parameter/nonce_factory_builder.rb",                  
                   "lib/secret_parameter/nonce.rb",                  
                   "lib/secret_parameter/packer.rb",                  
                   "lib/secret_parameter/secret_parameter.rb",                  
                   "lib/secret_parameter/secure_channel.rb"]                   
end
