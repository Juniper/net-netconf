require 'net/netconf/jnpr'

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }

Netconf::SSH.new( login ){ |dev|
  
  configs = dev.rpc.get_configuration{ |x|
    x.interfaces( :matching => 'interface[name="ge-*"]' )
  }
  
  ge_cfgs = configs.xpath('interfaces/interface')
  
  puts "There are #{ge_cfgs.count} GE interfaces:"
  ge_cfgs.each{|ifd|     
    units = ifd.xpath('unit').count    
    puts "   " + ifd.xpath('name')[0].text  + " with #{units} unit" + ((units>1) ? "s" : '')    
  }  
}
