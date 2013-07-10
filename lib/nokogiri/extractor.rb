module Nokogiri; end
class Nokogiri::Extractor
  VERSION = "1.0.0"
end
require 'nokogiri'
require 'andand'
module Nokogiri
  module XML
    class Document
      ###
      # Decorates the nodes of a Nokogiri document with extract methods to
      # allow quick acess to text.
      #
      def extractor!
        unless decorators(XML::Node).include? Nokogiri::Decorators::Extractor
          decorators(XML::Node) << Nokogiri::Decorators::Extractor
        end
        unless decorators(XML::NodeSet).include? Nokogiri::Decorators::Extractor
          decorators(XML::NodeSet) << Nokogiri::Decorators::Extractor
        end
        decorate!
      end
    end
  end
  module Decorators
    module Extractor
      ###
      # Returns text within the first element matching the selector(s). If you are looking for a 
      # node and not data, use search. Defaults to the text in the matched node,
      # but can read attributes and filter results with a regular expression.
      #
      # Ex:
      #   node.extract("a.class", attr: :href)
      #
      def extract(*selectors, &block)
        options = selectors.last.is_a?(Hash) ? selectors.pop : {}
        result = search(*selectors).first
        process(result,options, &block) if result
      end

      ###
      # Like extract, but returns an array of results for all matching nodes.
      # The block is only run against 
      #
      def extract_all(*selectors,&block)
        options = selectors.last.is_a?(Hash) ? selectors.pop : {}
        search(*selectors).map do |result|
          process(result,options,&block)
        end
      end

      ###
      # Attempts to match by the passed in selector and will return a concatenation
      # of all texty things in all child elements. If an attr is passed, process will
      # return that attribute. If a block is passed, the result will be executed
      # in that context. Don't cascade because process may render nil, opt for the
      # block syntax.
      #
      def process(item,options)
        result_text = (options[:attr] ? item[options[:attr]] : item.text)
          .andand.match(options[:regexp]|| /(.*)/) {|m| result_text = m[1]}
        result_text && block_given? ? yield(result_text, item) : result_text
      end
    end
  end
end
