# frozen_string_literal: true

require_relative "../jmdict/reader"

module JD
  module Jmdictpri
    # Reads priority entry elements from a JMdict XML file.
    class Reader < JD::Jmdict::Reader
      protected

      def read_each(stream)
        super { |entry| yield entry if priority_entry?(entry) }
      end

      def priority_entry?(entry)
        any_ke_pri?(entry) || any_re_pri?(entry)
      end

      def any_ke_pri?(entry)
        entry[:k_ele]&.each { |el| return true if el.key?(:ke_pri) }
        false
      end

      def any_re_pri?(entry)
        entry[:r_ele].each { |el| return true if el.key?(:re_pri) }
        false
      end
    end
  end
end
