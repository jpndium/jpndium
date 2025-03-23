# frozen_string_literal: true

require_relative "../file_reader"

module JD
  module Chiseids
    # Reads CHISE-IDS ideograph files.
    class Reader < JD::FileReader
      def read_line(line)
        return nil if line.start_with?(";;")

        codepoint, character, ids = line.strip.split("\t")
        { codepoint:, character:, ids: }
      end
    end
  end
end
