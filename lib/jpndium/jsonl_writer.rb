# frozen_string_literal: true

module JD
  # Writes lines to a jsonl file.
  class JsonlWriter < JD::FileWriter
    def write(value)
      super(JSON.dump(value))
    end
  end
end
