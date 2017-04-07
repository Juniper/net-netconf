# frozen_string_literal: true

module Netconf
  module RPC
    MSG_END = ']]>]]>'
    MSG_END_RE = /\]\]>\]\]>[\r\n]*$/
    MSG_CLOSE_SESSION = '<rpc><close-session/></rpc>'
    MSG_HELLO = <<-EOM.gsub(/\s+\|/, '')
      |<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
      |  <capabilities>
      |    <capability>urn:ietf:params:netconf:base:1.0</capability>
      |  </capabilities>
      |</hello>
    EOM

    module Standard
      def lock(target)
        run_valid_or_lock_rpc("<lock><target><#{target}/></target></lock>",
                              Netconf::LockError)

      end

      def unlock(target)
        rpc = Nokogiri::XML("<rpc><unlock><target><#{target}/></target></unlock></rpc>").root
        @trans.rpc_exec(rpc)
      end

      def validate(source)
        run_valid_or_lock_rpc("<validate><source><#{source}/></source></validate>",
                              Netconf::ValidateError)

      end

      def run_valid_or_lock_rpc(rpc_string, error_type)
        rpc = Nokogiri::XML("<rpc>#{rpc_string}</rpc>").root
        Netconf::RPC.set_exception(rpc, error_type)
        @trans.rpc_exec(rpc)
      end

      def commit
        rpc = Nokogiri::XML('<rpc><commit/></rpc>').root
        Netconf::RPC.set_exception(rpc, Netconf::CommitError)
        @trans.rpc_exec(rpc)
      end

      def delete_config(target)
        rpc = Nokogiri::XML("<rpc><delete-config><target><#{target}/></target></delete-config></rpc>").root
        @trans.rpc_exec(rpc)
      end

      def process_args(args)
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
      end

      def get_config(*args) # :yield: filter_builder
        source = 'running'    # default source is 'running'
        filter = nil          # no filter by default

        arg = process_args(args)

        rpc = Nokogiri::XML("<rpc><get-config><source><#{source}/></source></get-config></rpc>").root

        if block_given?
          Nokogiri::XML::Builder.with(rpc.at('get-config')) do |xml|
            xml.filter(type: 'subtree') { yield(xml) }
          end
        end

        if filter
          f_node = Nokogiri::XML::Node.new('filter', rpc)
          f_node['type'] = 'subtree'
          f_node << filter.dup
          rpc.at('get-config') << f_node
        end

        @trans.rpc_exec(rpc)
      end

      def edit_config(*args) # :yield: config_builder
        toplevel = 'config'  # default toplevel config element
        target = 'candidate' # default source is 'candidate'  @@@/JLS hack; need to fix this
        config = nil
        options = {}

        arg = process_args(args)
        toplevel = options[:toplevel] if options[:toplevel]

        rpc_str = <<-EO_RPC.gsub(/^\s*\|/, '')
          |<rpc>
          |  <edit-config>
          |     <target><#{target}/></target>
          |     <#{toplevel}/>
          |  </edit-config>
          |</rpc>
        EO_RPC

        rpc = Nokogiri::XML(rpc_str).root

        if block_given?
          Nokogiri::XML::Builder.with(rpc.at(toplevel)) { |xml| yield(xml) }
        elsif config
          rpc.at(toplevel) << config.dup
        else
          raise ArgumentError, 'You must specify edit-config data!'
        end

        Netconf::RPC.set_exception(rpc, Netconf::EditError)
        @trans.rpc_exec(rpc)
      end
    end
  end # module: RPC
end # module: Netconf
