# frozen_string_literal: true

module Jpndium
  # Writes lines to a directory of files.
  class DirectoryWriter < Jpndium::FileWriter
    DEFAULT_MAX_LINES = 100_000
    DEFAULT_MAX_DIGITS = 3
    DEFAULT_FILE_EXTENSION = "txt"

    def initialize(path, max_lines: nil, max_digits: nil, file_extension: nil)
      super(path)
      @max_lines = max_lines || DEFAULT_MAX_LINES
      @max_digits = max_digits || DEFAULT_MAX_DIGITS
      @file_extension = file_extension || DEFAULT_FILE_EXTENSION
    end

    def open
      @files = {}
      @index = 0

      if block_given?
        yield self
        close
      end

      self
    end

    def write(value)
      open unless @files
      current_file.write(value, "\n")
      @index += 1
      self
    end

    def close
      @files&.each_value(&:close)
      self
    end

    protected

    def current_file
      num = current_file_number
      return @files[num] if @files.key?(num)

      @files[num] = File.open(current_file_path, "w")
    end

    def current_file_path
      File.join(@path, current_filename)
    end

    def current_filename
      "#{current_file_number_padded}.#{@file_extension}"
    end

    def current_file_number_padded
      current_file_number.to_s.rjust(@max_digits, "0")
    end

    def current_file_number
      (@index / @max_lines) + 1
    end
  end
end
