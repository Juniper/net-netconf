require 'net/netconf/jnpr/telnet'

puts "NETCONF v#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }

Netconf::Telnet.new( login ){ |dev|  
  inv = dev.rpc.get_chassis_inventory    
  puts "Chassis: " + inv.xpath('chassis/description').text
  puts "Chassis Serial-Number: " + inv.xpath('chassis/serial-number').text
  
}


