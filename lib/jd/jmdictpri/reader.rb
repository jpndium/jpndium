# frozen_string_literal: true

module JD
  module Jmdictpri
    # Reads priority entry elements from jmdict jsonl files.
    class Reader < JD::JsonlDirectoryReader
      include JD::Jmdictpri::PriorityFilter
    end
  end
end
