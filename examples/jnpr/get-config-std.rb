require 'net/netconf'

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }
  
puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected."

  # ----------------------------------------------------------------------  
  # retrieve the full config.  Default source is 'running'
  # Alternatively you can pass the source name as a string parameter 
  # to #get_config
  
  puts "Retrieving full config, please wait ... "
  cfgall = dev.rpc.get_config                   
  puts "Showing 'system' hierarchy ..."
  puts cfgall.xpath('configuration/system')     # JUNOS toplevel config element is <configuration> 

  # ----------------------------------------------------------------------  
  # specifying a filter as a block to get_config
  
  cfgsvc1 = dev.rpc.get_config{ |x|
    x.configuration { x.system { x.services }}
  }
  
  puts "Retrieved services as BLOCK:"
  cfgsvc1.xpath('//services/*').each{|s| puts s.name }
  
  # ----------------------------------------------------------------------
  # specifying a filter as a parameter to get_config
  
  filter = Nokogiri::XML::Builder.new{ |x|
    x.configuration { x.system { x.services }}
  }
  
  cfgsvc2 = dev.rpc.get_config( filter )
  puts "Retrieved services as PARAM:"  
  cfgsvc2.xpath('//services/*').each{|s| puts s.name }
  
  cfgsvc3 = dev.rpc.get_config( filter )
  puts "Retrieved services as PARAM, re-used filter"  
  cfgsvc3.xpath('//services/*').each{|s| puts s.name }        
}



