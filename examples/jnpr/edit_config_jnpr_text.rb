require 'net/netconf/jnpr'

puts "NETCONF v.#{Netconf::VERSION}"

login = {
  target: 'vsrx',
  username: 'jeremy',
  password: 'jeremy1'
}

new_host_name = 'vsrx-gizmo'

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts '  Connected!'

  location = <<EOCONF
system {
   location {
      building "Main Campus, E"
      floor 15
      rack 1117
   }
}
EOCONF

  begin
    dev.rpc.lock_configuration

    # --------------------------------------------------------------------
    # configuration as BLOCK
    dev.rpc.load_configuration(format: 'text') do
      <<-EOCONF
      system {
        host-name #{new_host_name}
      }
EOCONF
    end
    # --------------------------------------------------------------------
    # configuration as PARAM

    dev.rpc.load_configuration(location, format: 'text')

    dev.rpc.check_configuration
    dev.rpc.commit_configuration
    dev.rpc.unlock_configuration
  rescue Netconf::LockError
    puts 'Lock error'
  rescue Netconf::EditError
    puts 'Edit error'
  rescue Netconf::ValidateError
    puts 'Validate error'
  rescue Netconf::CommitError
    puts 'Commit error'
  rescue Netconf::RpcError
    puts 'General RPC error'
  else
    puts 'Configuration Committed.'
  end
end
