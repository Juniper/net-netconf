require 'net/netconf'

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }
  
new_host_name = "vsrx-abc"

puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected!"
  
  target = 'candidate'
  
  location = Nokogiri::XML::Builder.new{ |x| x.configuration {
    x.system {
      x.location {
        x.building "Main Campus, A"
        x.floor 5
        x.rack 27
      }
    }
  }}
  
  begin
    
    rsp = dev.rpc.lock target

    # --------------------------------------------------------------------    
    # configuration as BLOCK
    
    rsp = dev.rpc.edit_config{ |x| x.configuration {
      x.system {
        x.send(:'host-name', new_host_name )
      }
    }}
    
    # --------------------------------------------------------------------
    # configuration as PARAM
    
    rsp = dev.rpc.edit_config( location )
    
    rsp = dev.rpc.validate target
    rpc = dev.rpc.commit
    rpc = dev.rpc.unlock target
    
  rescue Netconf::LockError => e
    puts "Lock error"
  rescue Netconf::EditError => e
    puts "Edit error"    
  rescue Netconf::ValidateError => e
    puts "Validate error"
  rescue Netconf::CommitError => e
    puts "Commit error"
  rescue Netconf::RpcError => e
    puts "General RPC error"
  else
    puts "Configuration Committed."
  end  
}



