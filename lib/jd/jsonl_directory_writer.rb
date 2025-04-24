# frozen_string_literal: true

module JD
  # Writes lines to a directory of jsonl files.
  class JsonlDirectoryWriter < JD::DirectoryWriter
    def initialize(*, **)
      super(*, file_extension: "jsonl", **)
    end

    def write(value)
      super(JSON.dump(value))
    end
  end
end
