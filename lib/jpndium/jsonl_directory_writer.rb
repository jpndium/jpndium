# frozen_string_literal: true

module Jpndium
  # Writes lines to a directory of jsonl files.
  class JsonlDirectoryWriter < Jpndium::DirectoryWriter
    def initialize(*, **)
      super(*, file_extension: "jsonl", **)
    end

    def write(value)
      super(JSON.dump(value))
    end
  end
end
