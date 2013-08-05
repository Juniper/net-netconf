module Netconf  
  module RPC
    
    MSG_END = "]]>]]>"
    MSG_END_RE = /\]\]>\]\]>[\r\n]*$/
    MSG_CLOSE_SESSION = '<rpc><close-session/></rpc>'       
    MSG_HELLO = <<-EOM
<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <capabilities>
    <capability>urn:ietf:params:netconf:base:1.0</capability>
  </capabilities>
</hello>
EOM

  module Standard
    
    def lock( target )      
      rpc = Nokogiri::XML( "<rpc><lock><target><#{target}/></target></lock></rpc>" ).root
      Netconf::RPC.set_exception( rpc, Netconf::LockError )
      @trans.rpc_exec( rpc )      
    end
    
    def unlock( target )
      rpc = Nokogiri::XML( "<rpc><unlock><target><#{target}/></target></unlock></rpc>" ).root
      @trans.rpc_exec( rpc )          
    end
    
    def validate( source )
      rpc = Nokogiri::XML( "<rpc><validate><source><#{source}/></source></validate></rpc>" ).root
      Netconf::RPC.set_exception( rpc, Netconf::ValidateError )      
      @trans.rpc_exec( rpc )          
    end
    
    def commit
      rpc = Nokogiri::XML( "<rpc><commit/></rpc>" ).root
      Netconf::RPC.set_exception( rpc, Netconf::CommitError )      
      @trans.rpc_exec( rpc )                
    end
    
    def delete_config( target )
      rpc = Nokogiri::XML( "<rpc><delete-config><target><#{target}/></target></delete-config></rpc>" ).root
      @trans.rpc_exec( rpc )          
    end
    
    def get_config( *args ) # :yeield: filter_builder
      
      source = 'running'    # default source is 'running'
      filter = nil          # no filter by default
      
      while arg = args.shift
        case arg.class.to_s
        when /^Nokogiri/ 
          filter = case arg
            when Nokogiri::XML::Builder  then arg.doc.root
            when Nokogiri::XML::Document then arg.root
            else arg
            end    
        when 'Hash' then attrs = arg
        when 'String' then source = arg
        end
      end
      
      rpc = Nokogiri::XML("<rpc><get-config><source><#{source}/></source></get-config></rpc>").root
      
      if block_given?
        Nokogiri::XML::Builder.with( rpc.at( 'get-config' )){ |xml|
          xml.filter( :type => 'subtree' ) {
            yield( xml )
          }
        }
      end
      
      if filter
        f_node = Nokogiri::XML::Node.new( 'filter', rpc )
        f_node['type'] = 'subtree'
        f_node << filter.dup   # copy filter, don't mess with the original since it may be re-used
        rpc.at('get-config') <<  f_node
      end             
            
      @trans.rpc_exec( rpc )      
    end

    def edit_config( *args ) # :yeield: config_builder
      
      toplevel = 'config'   # default toplevel config element
      target = 'candidate'  # default source is 'candidate'  @@@/JLS hack; need to fix this
      config = nil
      options = {}
      
      while arg = args.shift
        case arg.class.to_s
        when /^Nokogiri/ 
          config = case arg
            when Nokogiri::XML::Builder  then arg.doc.root
            when Nokogiri::XML::Document then arg.root
            else arg
            end    
        when 'Hash' then options = arg
        when 'String' then target = arg
        end
      end
      
      toplevel = options[:toplevel] if options[:toplevel]

      rpc_str = <<-EO_RPC
<rpc>
<edit-config>
   <target><#{target}/></target>
   <#{toplevel}/>
</edit-config>
</rpc>
EO_RPC

      rpc = Nokogiri::XML( rpc_str ).root
      
      if block_given?
        Nokogiri::XML::Builder.with(rpc.at( toplevel )){ |xml|
          yield( xml )
        }
      elsif config
        rpc.at( toplevel ) << config.dup
      else
        raise ArgumentError, "You must specify edit-config data!"    
      end                    
      
      Netconf::RPC.set_exception( rpc, Netconf::EditError )    
      @trans.rpc_exec( rpc )      
    end    
        
  end

  end # module: RPC  
end # module: Netconf
