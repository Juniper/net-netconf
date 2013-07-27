module Netconf
  
  class InitError < StandardError
  end
  
  class StateError < StandardError
  end
  
  class OpenError < StandardError
  end
  
  class RpcError < StandardError
    attr_reader :trans
    attr_reader :cmd, :rsp
    
    def initialize( trans, cmd, rsp )
      @trans = trans
      @cmd = cmd; @rsp = rsp; 
    end
    
    def to_s
      "RPC command error: #{cmd.first_element_child.name}\n#{rsp.to_xml}"
    end
  end
  
  class EditError < Netconf::RpcError
  end
  
  class LockError < Netconf::RpcError
  end
  
  class CommitError < Netconf::RpcError
  end
  
  class ValidateError < Netconf::RpcError
  end

end
