# frozen_string_literal: true

module Jpndium
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
      tap { @file.write(value, "\n") }
    end

    def close
      tap { @file&.close }
    end
  end
end
