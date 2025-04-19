# frozen_string_literal: true

require_relative "../xml_reader"

module JD
  module Jmdict
    # Reads entry elements from a JMdict XML file.
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
          sense: find_map(element, "sense", &method(:read_sense))
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
          re_nokanji: !find_first(element, "re_nokanji").nil? || nil,
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

      def read_sense(element)
        compact({
          stagk: find_content(element, "stagk"),
          stagr: find_content(element, "stagr"),
          pos: find_content(element, "pos"),
          xref: find_content(element, "xref"),
          ant: find_content(element, "ant"),
          field: find_content(element, "field"),
          misc: find_content(element, "misc"),
          s_inf: find_content(element, "s_inf"),
          lsource: find_map(element, "lsource", &method(:read_lsource)),
          dial: find_content(element, "dial"),
          gloss: find_map(element, "gloss", &method(:read_gloss))
        })
      end

      def read_lsource(element)
        compact({
          value: compact_content(element),
          lang: read_lang(element),
          ls_type: element.attr("ls_type"),
          ls_wasei: element.attr("ls_wasei")
        })
      end

      def read_gloss(element)
        compact({
          value: compact_content(element),
          lang: read_lang(element),
          g_gend: element.attr("g_gend"),
          g_type: element.attr("g_type")
        })
      end

      def read_lang(element)
        element.attr("xml:lang").then { |lang| lang unless lang == "eng" }
      end
    end
  end
end
