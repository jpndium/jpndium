# frozen_string_literal: true

module Jpndium
  module Kanjidic
    # Resolves kanjidic dependency information using chiseidsdep.
    class DependencyResolver < Jpndium::CompositionDependencyResolver
      FILTER_FIELDS = %w[composition dependencies dependents].freeze

      def initialize(kanjidic, chiseidsdep)
        super(nil)
        @kanjidic = kanjidic
        @chiseidsdep = chiseidsdep
      end

      protected

      def resolve_each
        @chiseidsdep
          .select(&method(:kanjidic_row?))
          .each { |r| yield filter_row(r) }
      end

      def kanjidic_row?(row)
        kanjidic_kanji?(row["character"])
      end

      def filter_row(row)
        row.tap do
          FILTER_FIELDS.each { |f| filter_field(row, f) }
        end
      end

      def filter_field(row, field)
        return unless row.key?(field)

        row[field] = keep_kanjidic_kanji(row[field])
        row.delete(field) if row[field].empty?
      end

      def keep_kanjidic_kanji(text)
        text.to_s.split.select(&method(:kanjidic_kanji?)).join(" ")
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
