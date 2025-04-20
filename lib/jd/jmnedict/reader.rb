# frozen_string_literal: true

require_relative "../xml_reader"

module JD
  module Jmnedict
    # Reads character elements from a JMnedict XML file.
    class Reader < JD::XmlReader
      def initialize
        super
        @element_name = "entry"
      end

      protected

      def read_element(element)
        compact({
          ent_seq: find_content(element, "ent_seq")&.first&.to_i,
          k_ele: find_map(element, "k_ele", &method(:read_k_ele)),
          r_ele: find_map(element, "r_ele", &method(:read_r_ele)),
          trans: find_map(element, "trans", &method(:read_trans))
        })
      end

      def read_k_ele(element)
        compact({
          keb: find_first_content(element, "keb"),
          ke_inf: find_content(element, "ke_inf"),
          ke_pri: read_pri(find_map(element, "ke_pri"))
        })
      end

      def read_r_ele(element)
        compact({
          reb: find_first_content(element, "reb"),
          re_restr: find_content(element, "re_restr"),
          re_inf: find_content(element, "re_inf"),
          re_pri: read_pri(find_map(element, "re_pri"))
        })
      end

      def read_pri(elements)
        elements
          &.each_with_object({}) do |element, hash|
            content = compact_content(element)
            key, value = content&.match(/([a-z]+)(\d+)/)&.captures
            hash[key.to_sym] = value.to_i if key && value
          end
      end

      def read_trans(element)
        compact({
          name_type: find_content(element, "name_type"),
          xref: find_content(element, "xref"),
          trans_det: find_map(element, "trans_det", &method(:read_trans_det))
        })
      end

      def read_trans_det(element)
        compact({
          value: compact_content(element),
          lang: read_lang(element)
        })
      end

      def read_lang(element)
        element.attr("xml:lang").then { |lang| lang unless lang == "eng" }
      end
    end
  end
end
