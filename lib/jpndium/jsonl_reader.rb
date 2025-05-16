# frozen_string_literal: true

module Jpndium
  # Reads lines from jsonl files.
  class JsonlReader < Jpndium::FileReader
    protected

    def read_line(line)
      JSON.parse(line)
    end
  end
end
