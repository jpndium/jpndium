# frozen_string_literal: true

module Jpndium
  module Chiseids
    # Reads CHISE-IDS ideograph files.
    class Reader < Jpndium::FileReader
      protected

      def read_each(...)
        super { |line| yield line if line }
      end

      def read_line(line)
        return nil if line.start_with?(";;")

        codepoint, character, ids = line.strip.split("\t")
        { codepoint:, character:, ids: }
      end
    end
  end
end
