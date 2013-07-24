require 'net/netconf/jnpr/serial'

puts "NETCONF v.#{Netconf::VERSION}"

serial_port = '/dev/ttyS4'

login = { :port => serial_port,
  :username => "jeremy", :password => "jeremy1" }

puts "Connecting to SERIAL: #{serial_port} ... please wait."

Netconf::Serial.new( login ){ |dev|
  
  puts "Connected."
  puts "Nabbing Inventory ..."

  inv = dev.rpc.get_chassis_inventory      
  
  puts "Chassis: " + inv.xpath('chassis/description').text
  puts "Chassis Serial-Number: " + inv.xpath('chassis/serial-number').text
  
}



