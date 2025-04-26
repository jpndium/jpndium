# frozen_string_literal: true

module JD
  module Jmdict
    # Reads priority entry elements from jmdict jsonl files.
    class PriorityReader < JD::JsonlDirectoryReader
      protected

      def read_file(path)
        super { |entry| yield entry if priority_entry?(entry) }
      end

      def priority_entry?(entry)
        any_ke_pri?(entry) || any_re_pri?(entry)
      end

      def any_ke_pri?(entry)
        entry["k_ele"]&.each { |el| return true if el.key?("ke_pri") }
        false
      end

      def any_re_pri?(entry)
        entry["r_ele"]&.each { |el| return true if el.key?("re_pri") }
        false
      end
    end
  end
end
