# frozen_string_literal: true

require 'net/netconf/jnpr'

puts "NETCONF v#{Netconf::VERSION}"

login = {
  target: 'ex4',
  username: 'jeremy',
  password: 'jeremy1'
}

new_host_name = 'ex4-abc'

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts 'Connected!'
  # when providing a collection of configuration,
  # you need to include the <configuration> as the
  # toplevel element
  location = Nokogiri::XML::Builder.new do |x|
    x.configuration do
      x.system do
        x.location do
          x.building 'Main Campus, D'
          x.floor 22
          x.rack 38
        end
      end
      x.system do
        x.services do
          x.ftp
        end
      end
    end
  end

  begin
    dev.rpc.lock_configuration

    # --------------------------------------------------------------------
    # configuration as PARAM

    dev.rpc.load_configuration(location, action: 'replace')

    # --------------------------------------------------------------------
    # configuration as BLOCK

    dev.rpc.load_configuration do |x|
      x.system do
        x.send(:'host-name', new_host_name)
      end
    end

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
