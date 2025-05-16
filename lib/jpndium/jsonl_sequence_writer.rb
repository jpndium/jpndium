# frozen_string_literal: true

module Jpndium
  # Writes lines to a sequence of jsonl files.
  class JsonlSequenceWriter < Jpndium::FileSequenceWriter
    def initialize(*, **)
      super(*, file_extension: "jsonl", **)
    end

    def write(value)
      super(JSON.dump(value))
    end
  end
end
