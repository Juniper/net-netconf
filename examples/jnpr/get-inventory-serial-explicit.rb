require 'net/netconf/jnpr/serial'

puts "NETCONF v.#{Netconf::VERSION}"

login = { 
  :port => '/dev/ttyS4', 
  :username => "root", :password => "juniper1" 
}

# we want to mount the USB drive, so we need to explicity
# do something special when opening the serial console ...
# therefore, we can *NOT* pass a block directly to new()

dev = Netconf::Serial.new( login )
dev.open { |con|
  # login has occurred successfully
  
  con.puts 'mount_msdosfs /dev/da1s1 /mnt'  
  
  # netconf will be started once block completes
}

inv = dev.rpc.get_chassis_inventory

dev.close


