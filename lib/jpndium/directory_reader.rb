# frozen_string_literal: true

module Jpndium
  # Reads a directory of files.
  class DirectoryReader
    DEFAULT_FILE_EXTENSION = "txt"

    def initialize(path, file_extension: nil)
      @path = path
      @file_extension = file_extension || DEFAULT_FILE_EXTENSION
    end

    def self.read(*, **, &)
      new(*, **).read(&)
    end

    def read(&)
      if block_given?
        read_each(&)
      else
        read_all
      end
    end

    protected

    def read_all
      values = []
      read_each { |value| values << value }

      values
    end

    def read_each(&)
      Dir.glob("#{@path}/*.#{@file_extension}") do |path|
        read_file(path, &)
      end
    end

    def read_file(path, &)
      file_reader.read_file(path, &)
    end

    private

    def file_reader
      @file_reader ||= Jpndium::FileReader.new
    end
  end
end
