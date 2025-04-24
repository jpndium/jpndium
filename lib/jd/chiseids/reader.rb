# frozen_string_literal: true

module JD
  module Chiseids
    # Reads CHISE-IDS ideograph files.
    class Reader < JD::FileReader
      protected

      def read_line(line)
        return nil if line.start_with?(";;")

        codepoint, character, ids = line.strip.split("\t")
        { codepoint:, character:, ids: }
      end
    end
  end
end
