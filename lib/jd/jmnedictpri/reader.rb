# frozen_string_literal: true

module JD
  module Jmnedictpri
    # Reads priority entry elements from a JMnedict XML file.
    class Reader < JD::Jmnedict::Reader
      include JD::Jmdictpri::PriorityFilter
    end
  end
end
