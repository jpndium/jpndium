# frozen_string_literal: true

module JD
  # Writes lines to a jsonl file.
  class JsonlWriter
    def initialize(path)
      @path = path
    end

    def self.open(*, **, &)
      new(*, **).open(&)
    end

    def open
      @file = File.open(@path, "w")

      if block_given?
        yield self
        close
      end

      self
    end

    def write(row)
      @file.write(JSON.dump(row), "\n")
      self
    end

    def close
      @file&.close
      self
    end
  end
end
