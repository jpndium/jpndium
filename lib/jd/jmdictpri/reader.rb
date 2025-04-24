# frozen_string_literal: true

module JD
  module Jmdictpri
    # Reads priority entry elements from a JMdict XML file.
    class Reader < JD::Jmdict::Reader
      include JD::Jmdictpri::PriorityFilter
    end
  end
end
