# frozen_string_literal: true

module Jpndium
  module Kanjidic
    # Resolves kanjidic dependency information using chiseidsdep.
    class DependencyResolver < Jpndium::DependencyResolver
      FILTER_FIELDS = %w[composition dependencies dependents].freeze

      def initialize(kanjidic, chiseidsdep)
        super
        @kanjidic = kanjidic
        @chiseidsdep = chiseidsdep
      end

      protected

      def resolve_each
        @chiseidsdep
          .select(&method(:kanjidic_row?))
          .each do |row|
            yield ({
              literal: row["character"],
              pattern: row["pattern"],
              composition: keep_kanjidic_kanji(row["composition"]),
              dependencies: keep_kanjidic_kanji(row["dependencies"]),
              dependents: keep_kanjidic_kanji(row["dependents"])
            }).compact
          end
      end

      def kanjidic_row?(row)
        kanjidic_kanji?(row["character"])
      end

      def keep_kanjidic_kanji(text)
        text.to_s
          .split
          .select(&method(:kanjidic_kanji?))
          .join(" ")
          .then { |s| s.empty? ? nil : s }
      end

      def kanjidic_kanji?(value)
        kanjidic_kanji.member?(value)
      end

      def kanjidic_kanji
        @kanjidic_kanji ||= @kanjidic.to_set { |row| row["literal"] }
      end
    end
  end
end
