# frozen_string_literal: true

module Jpndium
  module Chiseids
    # Resolves chiseids dependency information.
    class DependencyResolver < Jpndium::DependencyResolver
      PREFIXES = <<~CHARACTERS.split.freeze
        ⿰ ⿱ ⿲ ⿳ ⿴ ⿵ ⿶ ⿷ ⿼ ⿸ ⿹ ⿺ ⿽ ⿻ ⿾ ⿿
      CHARACTERS

      def initialize(chiseids)
        super(nil)
        @chiseids = chiseids
      end

      private

      def fetch_resolution(value)
        super.then do |resolution|
          character = resolution[:value]
          {
            character: character,
            pattern: list_string(patterns.fetch(character, nil)),
            composition: list_string(compositions[character]),
            dependencies: list_string(resolution[:dependencies]),
            dependents: list_string(resolution[:dependents])
          }.compact
        end
      end

      def patterns
        @patterns ||= @chiseids.to_h do |row|
          pattern = row["ids"].chars.select(&PREFIXES.method(:include?))
          [row["character"], pattern]
        end
      end

      def compositions
        @compositions ||= @chiseids
          .to_h do |row|
            composition = (split_ids(clean_ids(row["ids"])) || [])
              .reject { |character| character == row["character"] }
            [row["character"], composition]
          end
      end

      def clean_ids(ids)
        ids
          .then(&method(:keep_only_first_sequence))
          .then(&method(:remove_text_in_brackets))
          .then(&method(:remove_spaces))
          .then(&method(:remove_prefixes))
      end

      def keep_only_first_sequence(ids)
        ids.gsub(%r{/.*}, "")
      end

      def remove_text_in_brackets(ids)
        ids.gsub(/\[[^\]]*\]/, "")
      end

      def remove_spaces(ids)
        ids.gsub(/\s/, "")
      end

      def remove_prefixes(ids)
        ids.chars.reject(&PREFIXES.method(:include?)).join
      end

      def split_ids(ids)
        ids
          .then { |i| split_on_codepoints(i) }
          .map do |part|
            next [part] if part.start_with?("&")

            part.chars
          end
          .reduce(:+)
      end

      def split_on_codepoints(ids)
        ids.split(/(&[^;]*;)/)
      end

      def list_string(value)
        return nil if value.nil? || value.empty?

        value.join(" ")
      end
    end
  end
end
