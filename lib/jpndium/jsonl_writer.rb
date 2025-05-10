# frozen_string_literal: true

module Jpndium
  # Writes lines to a jsonl file.
  class JsonlWriter < Jpndium::FileWriter
    def write(value)
      super(JSON.dump(value))
    end
  end
end
