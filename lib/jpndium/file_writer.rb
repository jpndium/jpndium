# frozen_string_literal: true

module JD
  # Writes lines to a file.
  class FileWriter
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

    def write(value)
      @file.write(value, "\n")
      self
    end

    def close
      @file&.close
      self
    end
  end
end
