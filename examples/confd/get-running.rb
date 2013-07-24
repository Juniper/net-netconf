#
# This code is used to retrieve the running configuration
# from a Tail-F "confD" NETCONF server, and display the
# configured user names
#

require 'net/netconf'

puts "NETCONF v#{Netconf::VERSION}"

login = { :target => 'jeap', :port => 2022,
  :username => "admin", :password => "admin" }

Netconf::SSH.new( login ){ |dev|  
  
  config = dev.rpc.get_config
  
  puts "Showing users on this device ..."
    
  config.xpath("//users/user").each{|user|
    puts "Username: #{user.xpath('name').text}"
  }
  
}



