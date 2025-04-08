# frozen_string_literal: true

require_relative "file_reader"

module JD
  # Reads lines from a jsonl file.
  class JsonlReader < JD::FileReader
    protected

    def read_line(line)
      JSON.parse(line)
    end
  end
end
