# frozen_string_literal: true

module Jpndium
  # Reads a directory of jsonl files.
  class JsonlDirectoryReader < Jpndium::DirectoryReader
    def initialize(*, **)
      super(*, file_extension: "jsonl", **)
    end

    protected

    def read_file(path, &)
      jsonl_reader.read_file(path, &)
    end

    private

    def jsonl_reader
      @jsonl_reader ||= Jpndium::JsonlReader.new
    end
  end
end
