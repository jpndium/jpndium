# frozen_string_literal: true

module Jpndium
  module Kanjidic
    # Reads rows from chiseidsdep and removes kanji not present in kanjidic.
    class DependencyResolver
      FILTER_FIELDS = %w[composition dependencies dependents].freeze

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
          .map(&method(:read_row))
      end

      private

      def read_row(row)
        row.clone.tap do |clone|
          FILTER_FIELDS.each do |field|
            next unless clone.key?(field)

            clone[field] = keep_kanjidic_kanji(clone[field])
            clone.delete(field) if clone[field].empty?
          end
        end
      end

      def keep_kanjidic_kanji(text)
        text
          .to_s
          .split
          .select(&method(:kanjidic_kanji?))
          .join(" ")
      end

      def kanjidic_kanji?(value)
        @kanjidic_kanji.member?(value)
      end
    end
  end
end
