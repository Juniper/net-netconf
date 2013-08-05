require 'net/netconf/rpc_std'

module Netconf  
  module RPC    
    
    def RPC.add_attributes( ele_nx, attr_h )
      attr_h.each{ |k,v| ele_nx[k] = v }      
    end
    
    def RPC.set_exception( rpc_nx, exception )
      rpc_nx.instance_variable_set(:@netconf_exception, exception )
    end
    
    def RPC.get_exception( rpc_nx )
      rpc_nx.instance_variable_get(:@netconf_exception) || Netconf::RpcError
    end
    
    module Builder      
      # autogenerate an <rpc>, converting underscores (_)
      # to hyphens (-) along the way ...
      
      def Builder.method_missing( method, params = nil, attrs = nil )    
        
        rpc_name = method.to_s.tr('_','-').to_sym        

        if params
          # build the XML starting at <rpc>, envelope the <method> toplevel element,
          # and then create name/value elements for each of the additional params.  An element
          # without a value should simply be set to true          
          rpc_nx = Nokogiri::XML::Builder.new { |xml|
            xml.rpc { xml.send( rpc_name ) {
              params.each{ |k,v|
                sym = k.to_s.tr('_','-').to_sym
                xml.send(sym, (v==true) ? nil : v )
              }
            }}
          }.doc.root
        else
          # -- no params 
          rpc_nx = Nokogiri::XML("<rpc><#{rpc_name}/></rpc>").root
        end
        
        # if a block is given it is used to set the attributes of the toplevel element         
        RPC.add_attributes( rpc_nx.at( rpc_name ), attrs ) if attrs      
        
        # return the rpc command
        rpc_nx               
      end # def: method-missing?            
      
    end # module: Builder      
    
    class Executor
      include Netconf::RPC::Standard
      
      def initialize( trans, os_type )
        @trans = trans
        begin  
          extend Netconf::RPC::const_get( os_type )                
        rescue NameError
          # no extensions available ...
        end        
      end
      
      def method_missing( method, params = nil, attrs = nil )
        @trans.rpc_exec( Netconf::RPC::Builder.send( method, params, attrs ))
      end        
    end # class: Executor
    
  end # module: RPC
end # module: Netconf
      
