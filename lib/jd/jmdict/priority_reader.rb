# frozen_string_literal: true

module JD
  module Jmdict
    # Reads priority entry elements from jmdict jsonl files.
    class PriorityReader < JD::JsonlDirectoryReader
      include JD::Jmdictpri::PriorityFilter
    end
  end
end
