# frozen_string_literal: true

module Jpndium
  # Writes lines to files.
  class FileWriter
    DEFAULT_MAX_LINES = 100_000
    DEFAULT_MAX_DIGITS = 3
    DEFAULT_FILE_EXTENSION = "txt"

    def initialize(path, **)
      @path = path
    end

    def self.sequence(*, **, &)
      new(*, **).sequence(**, &)
    end

    def self.open(*, **, &)
      new(*, **).open(&)
    end

    def sequence(max_lines: nil, max_digits: nil, file_extension: nil, &)
      @max_lines = max_lines || self.class::DEFAULT_MAX_LINES
      @max_digits = max_digits || self.class::DEFAULT_MAX_DIGITS
      @file_extension = file_extension || self.class::DEFAULT_FILE_EXTENSION
      self.open(&)
    end

    def open
      return self unless block_given?

      (yield self).then { close }
    end

    def write(line)
      tap do
        file.write(line, "\n")
        increment_line_number
      end
    end

    def close
      tap do
        files.each_value(&:close)
        @files = nil
        @line_number = nil
      end
    end

    protected

    def file
      num = file_number
      return files[num] if files.key?(num)

      files[num] = File.open(path, "w")
    end

    def files
      @files ||= {}
    end

    def path
      return @path unless sequencing?

      File.join(@path, filename)
    end

    def filename
      "#{file_number_padded}.#{@file_extension}"
    end

    def file_number_padded
      file_number.to_s.rjust(@max_digits, "0")
    end

    def file_number
      return 0 unless sequencing?

      (line_number / @max_lines) + 1
    end

    def increment_line_number
      @line_number = line_number + 1
    end

    def line_number
      @line_number ||= 0
    end

    def sequencing?
      !!@max_lines
    end
  end
end
