Gem::Specification.new do |s|
  s.name          = 'sdee'
  s.version       = '0.0.1'
  s.summary       = 'Simple Ruby SDEE Poller'
  s.description   = 'Secure Device Event Exchange (SDEE) is a simple HTTP-based protocol used by security appliances to exchange events and alerts. Resutls are returned in XML. This is a very bare-bones ruby implementation to get SDEE events from a Cisco IPS in JSON format.'
  s.authors       = ['Jamil Bou Kheir']
  s.email         = 'jamil@elbii.com'
  s.files         = ['lib/sdee.rb', 'example.rb']
  s.homepage      = 'https://github.com/elbii/ruby-sdee'
  s.licenses      = ['GPL-2']
  s.add_runtime_dependency 'nokogiri', '~> 1.5.0', '>= 1.5.0'
end
