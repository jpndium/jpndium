# frozen_string_literal: true

require_relative "../xml_reader"

module JD
  module Kanjidic
    # Reads character elements from a KANJIDIC2 XML file.
    class XmlReader < JD::XmlReader
      def initialize
        super
        @element_name = "character"
      end

      def read_one(element)
        compact({
          literal: find_content(element, "literal")&.first,
          codepoint: read_codepoint(find_first(element, "codepoint")),
          radical: read_radical(find_first(element, "radical")),
          misc: read_misc(find_first(element, "misc")),
          dic_number: read_dic_number(find_first(element, "dic_number")),
          query_code: read_query_code(find_first(element, "query_code")),
          reading_meaning: read_reading_meaning(
            find_first(element, "reading_meaning")
          )
        })
      end

      def read_codepoint(element)
        compact({
          cp_value: find_map(element, "cp_value") { |e| read_cp_value(e) }
        })
      end

      def read_cp_value(element)
        compact({
          value: compact_content(element),
          cp_type: element.attr("cp_type")
        })
      end

      def read_radical(element)
        compact({
          rad_value: find_map(element, "rad_value") { |e| read_rad_value(e) }
        })
      end

      def read_rad_value(element)
        compact({
          value: compact_content(element)&.to_i,
          rad_type: element.attr("rad_type")
        })
      end

      def read_misc(element)
        compact({
          grade: find_first_content(element, "grade")&.to_i,
          stroke_count: find_content(element, "stroke_count")&.map(&:to_i),
          variant: find_map(element, "variant") { |e| read_variant(e) },
          freq: find_first_content(element, "freq")&.to_i,
          rad_name: find_content(element, "rad_name"),
          jlpt: find_first_content(element, "jlpt")&.to_i
        })
      end

      def read_variant(element)
        compact({
          value: compact_content(element),
          var_type: element.attr("var_type")
        })
      end

      def read_dic_number(element)
        compact({
          dic_ref: find_map(element, "dic_ref") { |e| read_dic_ref(e) }
        })
      end

      def read_dic_ref(element)
        compact({
          value: compact_content(element)&.to_i,
          dr_type: element.attr("dr_type"),
          m_vol: element.attr("m_vol")&.to_i,
          m_page: element.attr("m_page")&.to_i
        })
      end

      def read_query_code(element)
        compact({
          q_code: find_map(element, "q_code") { |e| read_q_code(e) }
        })
      end

      def read_q_code(element)
        compact({
          value: compact_content(element),
          qc_type: element.attr("qc_type"),
          skip_misclass: element.attr("skip_misclass")
        })
      end

      def read_reading_meaning(element)
        compact({
          rmgroup: find_map(element, "rmgroup") { |e| read_rmgroup(e) },
          nanori: find_content(element, "nanori")
        })
      end

      def read_rmgroup(element)
        compact({
          reading: find_map(element, "reading") { |e| read_reading(e) },
          meaning: find_map(element, "meaning") { |e| read_meaning(e) }
        })
      end

      def read_reading(element)
        compact({
          value: compact_content(element),
          r_type: element.attr("r_type"),
          on_type: element.attr("on_type"),
          r_status: element.attr("r_status")
        })
      end

      def read_meaning(element)
        compact({
          value: compact_content(element),
          m_lang: element.attr("m_lang")
        })
      end
    end
  end
end
