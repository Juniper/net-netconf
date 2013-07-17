$LOAD_PATH.unshift 'lib'
require 'net/netconf/version'

Gem::Specification.new do |s|
  s.name = 'netconf'
  s.version = Netconf::VERSION
  s.summary = "NETCONF client"
  s.description = "Extensible Ruby-based NETCONF client"
  s.homepage = 'https://github.com/Juniper-Workflow/net-netconf'
  s.authors = ["Jeremy Schulman", "Ankit Jain"]
  s.email = 'jschulman@juniper.net'

  s.files         = `git ls-files`.split $/
  s.test_files    = gem.files.grep /^test/
  s.require_paths = ["lib"]

  s.add_dependency('nokogiri', '>= 1.5.5')
  s.add_dependency('net-ssh', '>= 2.5.2')
end
