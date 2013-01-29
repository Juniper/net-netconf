#
# Copyright (c) 2012 Juniper Networks, Inc.
# All Rights Reserved
#
# JUNIPER PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.

module Netconf

  class JunosConfig

    DELETE = { :delete => 'delete' }
    REPLACE = { :replace => 'replace' }
 
    attr_reader :doc
    attr_reader :collection

    def initialize( options )
      @doc_ele = "configuration"

      if options == :TOP
        @doc = Nokogiri::XML("<#{@doc_ele}/>")
        return
      end

      unless options[:TOP].nil?
        @doc_ele = options[:TOP]
        @doc = Nokogiri::XML("<#{@doc_ele}/>")
        return
      end

      unless defined? @collection
        edit = "#{@doc_ele}/#{options[:edit].strip}"
        @at_name = edit[edit.rindex('/') + 1, edit.length]
        @edit_path = edit
        @collection = Hash.new
        @to_xml = options[:build]
      end
    end

    def <<( obj )
      if defined? @collection
        @collection[obj[:name]] = obj
      elsif defined? @doc
        obj.build_xml( @doc )
      else
        # TBD:error
      end
    end

    def build_xml( ng_xml, &block )
      at_ele = ng_xml.at( @edit_path )
      if at_ele.nil?
        # no xpath anchor point, so we need to create it
        at_ele = edit_path( ng_xml, @edit_path )
      end
      build_proc = (block_given?) ? block : @to_xml

      @collection.each do |k,v|
        with( at_ele ) do |e|
          build_proc.call( e, v )
        end
      end
    end

    def edit_path( ng_xml, xpath )
      # junos configuration always begins with
      # the 'configuration' element, so don't make
      # the user enter it all the time

      cfg_xpath = xpath
      dot = ng_xml.at( cfg_xpath )
      return dot if dot

      # we need to determine how much of the xpath
      # we need to create.  walk down the xpath
      # children to determine what exists and
      # what needs to be added

      xpath_a = cfg_xpath.split('/')
      need_a = []
      until xpath_a.empty? or dot
        need_a.unshift xpath_a.pop
        check_xpath = xpath_a.join('/')
        dot = ng_xml.at( check_xpath )
      end

      # start at the deepest level of what
      # actually exists and then start adding
      # the children that were missing

      dot = ng_xml.at(xpath_a.join('/'))
      need_a.each do |ele|
        dot = dot.add_child( Nokogiri::XML::Node.new( ele, ng_xml ))
      end
      return dot
    end

    def with( ng_xml, &block )
      Nokogiri::XML::Builder.with( ng_xml, &block )
    end
  end
   #-- class end
end

