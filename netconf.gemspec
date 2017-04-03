$LOAD_PATH.unshift 'lib'
require 'rake'
require 'net/netconf/version'

Gem::Specification.new do |s|
  s.name = 'netconf'
  s.version = Netconf::VERSION
  s.summary = "NETCONF client"
  s.description = "Extensible Ruby-based NETCONF client"
  s.homepage = 'https://github.com/Juniper/net-netconf'
  s.authors = ["Jeremy Schulman", "Ankit Jain", "David Gethings"]
  s.email = 'dgjnpr@gmail.com'
  s.files = FileList['lib/net/**/*.rb', 'examples/**/*.rb']
  s.add_dependency('nokogiri', '>= 1.5.5')
  s.add_dependency('net-ssh', '>= 2.5.2')
  s.add_dependency('net-scp')
  # s.add_development_dependency('rake', '~> 12.0')
  # s.add_development_dependency('rspec-core', '~> 3.5')
  # s.add_development_dependency('rspec-expectations', '~> 3.5')
  # s.add_development_dependency('cucumber', '~> 2.4')
  s.add_development_dependency('rubocop', '~> 0.48')
end
