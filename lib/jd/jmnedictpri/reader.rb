# frozen_string_literal: true

require_relative "../jmnedict/reader"
require_relative "../jmdictpri/priority_filter"

module JD
  module Jmnedictpri
    # Reads priority entry elements from a JMnedict XML file.
    class Reader < JD::Jmnedict::Reader
      include JD::Jmdictpri::PriorityFilter
    end
  end
end
