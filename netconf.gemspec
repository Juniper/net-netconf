$LOAD_PATH.unshift 'lib'
require 'rake'
require 'net/netconf/version'

Gem::Specification.new do |s|
  s.name = 'netconf'
  s.licenses = ['JSSL']
  s.version = Netconf::VERSION
  s.summary = "NETCONF client"
  s.description = "Extensible Ruby-based NETCONF client with native support for Junos. Maintained by Juniper Networks"
  s.homepage = 'https://github.com/Juniper/net-netconf'
  s.authors = ["Jeremy Schulman", "Ankit Jain"]
  s.email = 'jschulman@juniper.net'
  s.license = 'BSD 2'
  s.files = FileList['lib/net/**/*.rb', 'examples/**/*.rb']
  s.add_dependency('nokogiri', '>= 1.6.4')
  s.add_dependency('net-ssh', '>= 2.5.2')
  s.add_dependency('net-scp')
end
