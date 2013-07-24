require 'net/netconf/jnpr'      # note: including Juniper specific extension

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'ex4', :username => "jeremy", :password => "jeremy1" }
  
puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected."
  
  puts "Retrieving full config, please wait ... "
  cfgall = dev.rpc.get_configuration                   # Junos specific RPC
  puts "Showing 'system' hierarchy ..."
  puts cfgall.xpath('system')                          # Root is <configuration>, so don't need to include it in XPath  

  # ----------------------------------------------------------------------  
  # specifying a filter as a block to get_configuration
  # Junos extension does the proper toplevel wrapping

  puts "Retrieved services from BLOCK, as XML:"
  
  cfgsvc1_1 = dev.rpc.get_configuration{ |x|
    x.system { x.services }
    x.system { x.login }
  }
  
  cfgsvc1_1.xpath('system/services/*').each{|s| puts s.name }

  puts "Retrieved services from BLOCK, as TEXT:"
  
  cfgsvc1_2 = dev.rpc.get_configuration( :format => 'text' ){ |x|
    x.system { x.services }
  }
  
  puts cfgsvc1_2.text
  
  # ----------------------------------------------------------------------
  # specifying a filter as a parameter to get_configuration
  # you must wrap the config in a toplevel <configuration> element
  
  filter = Nokogiri::XML::Builder.new{ |x| x.configuration {
    x.system { x.services }
    x.system { x.login }
  }}

  puts "Retrieved services by PARAM, as XML"  
  
  cfgsvc2 = dev.rpc.get_configuration( filter )
  cfgsvc2.xpath('system/services/*').each{|s| puts s.name }

  # ----------------------------------------------------------------------
  # specifying a filter as a parameter to get_configuration,
  # get response back in "text" format

  puts "Retrieved services by PARAM, as TEXT:"    
  cfgsvc3 = dev.rpc.get_configuration( filter, :format => 'text' )
  puts cfgsvc3.text
}



