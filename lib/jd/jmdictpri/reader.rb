# frozen_string_literal: true

require_relative "../jmdict/reader"
require_relative "../jmdictpri/priority_filter"

module JD
  module Jmdictpri
    # Reads priority entry elements from a JMdict XML file.
    class Reader < JD::Jmdict::Reader
      include JD::Jmdictpri::PriorityFilter
    end
  end
end
