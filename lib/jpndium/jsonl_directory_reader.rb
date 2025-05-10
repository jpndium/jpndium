# frozen_string_literal: true

module JD
  # Reads a directory of jsonl files.
  class JsonlDirectoryReader < JD::DirectoryReader
    def initialize(*, **)
      super(*, file_extension: "jsonl", **)
    end

    protected

    def read_file(path, &)
      jsonl_reader.read_file(path, &)
    end

    private

    def jsonl_reader
      @jsonl_reader ||= JD::JsonlReader.new
    end
  end
end
