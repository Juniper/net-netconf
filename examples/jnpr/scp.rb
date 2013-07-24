require 'net/netconf'
require 'net/scp'

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }

file_name = __FILE__  

Netconf::SSH.new( login ){ |dev|  

  inv = dev.rpc.get_chassis_inventory  

  puts "Chassis: " + inv.xpath('chassis/description').text
  puts "Chassis Serial-Number: " + inv.xpath('chassis/serial-number').text  
    
  puts "Copying file #{file_name} to home directory ..."  
  dev.scp.upload! file_name, file_name
 
  puts "Copying latest config file from target to local machine ..."
  
  dev.scp.download! "/config/juniper.conf.gz", "/var/tmp/config.gz"
}

