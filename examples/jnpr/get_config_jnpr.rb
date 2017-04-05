require 'net/netconf/jnpr'

puts "NETCONF v.#{Netconf::VERSION}"

login = {
  target: 'ex4',
  username: 'jeremy',
  password: 'jeremy1'
}

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts 'Connected.'

  puts 'Retrieving full config, please wait ... '
  # Junos specific RPC
  cfgall = dev.rpc.get_configuration
  puts "Showing 'system' hierarchy ..."
  # Root is <configuration>, so don't need to include it in XPath
  puts cfgall.xpath('system')

  # ----------------------------------------------------------------------
  # specifying a filter as a block to get_configuration
  # Junos extension does the proper toplevel wrapping

  puts 'Retrieved services from BLOCK, as XML:'

  cfgsvc1 = dev.rpc.get_configuration do |x|
    x.system { x.services }
    x.system { x.login }
  end

  cfgsvc1.xpath('system/services/*').each { |s| puts s.name }

  puts 'Retrieved services from BLOCK, as TEXT:'

  cfgsvc2 = dev.rpc.get_configuration(format: 'text') do |x|
    x.system { x.services }
  end

  puts cfgsvc2.text

  # ----------------------------------------------------------------------
  # specifying a filter as a parameter to get_configuration
  # you must wrap the config in a toplevel <configuration> element

  filter = Nokogiri::XML::Builder.new do |x|
    x.configuration do
      x.system { x.services }
      x.system { x.login }
    end
  end

  puts 'Retrieved services by PARAM, as XML'

  cfgsvc3 = dev.rpc.get_configuration(filter)
  cfgsvc3.xpath('system/services/*').each { |s| puts s.name }

  # ----------------------------------------------------------------------
  # specifying a filter as a parameter to get_configuration,
  # get response back in "text" format

  puts 'Retrieved services by PARAM, as TEXT:'
  cfgsvc4 = dev.rpc.get_configuration(filter, format: 'text')
  puts cfgsvc4.text
end
