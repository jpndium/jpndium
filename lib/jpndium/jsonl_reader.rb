# frozen_string_literal: true

module Jpndium
  # Reads lines from a jsonl file.
  class JsonlReader < Jpndium::FileReader
    protected

    def read_line(line)
      JSON.parse(line)
    end
  end
end
