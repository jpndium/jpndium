# frozen_string_literal: true

module JD
  module Kanjidic
    # Reads rows from chiseidsdep and removes kanji not present in kanjidic.
    class DependencyReader
      def initialize(kanjidic, chiseidsdep)
        @kanjidic = kanjidic
        @kanjidic_kanji = kanjidic.to_set { |row| row["literal"] }
        @chiseidsdep = chiseidsdep
      end

      def self.read(kanjidic, chiseidsdep)
        new(kanjidic, chiseidsdep).read
      end

      def read
        @chiseidsdep
          .select { |row| @kanjidic_kanji.member?(row["character"]) }
          .map { |row| read_row(row) }
      end

      private

      def read_row(row)
        {
          character: row["character"],
          pattern: row["pattern"],
          composition: keep_kanjidic_kanji(row["composition"]),
          dependencies: keep_kanjidic_kanji(row["dependencies"]),
          dependents: keep_kanjidic_kanji(row["dependents"])
        }
      end

      def keep_kanjidic_kanji(text)
        text
          .to_s
          .split
          .select { |character| kanjidic_kanji?(character) }
          .join(" ")
      end

      def kanjidic_kanji?(value)
        @kanjidic_kanji.member?(value)
      end
    end
  end
end
