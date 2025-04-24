# frozen_string_literal: true

module JD
  module Kanjidep
    # Reads chiseids jsonl files and derives dependency information for each
    # Ideographic Description Sequence (IDS).
    class Reader
      PREFIXES = <<~CHARACTERS.split.freeze
        ⿰ ⿱ ⿲ ⿳ ⿴ ⿵ ⿶ ⿷ ⿼ ⿸ ⿹ ⿺ ⿽ ⿻ ⿾ ⿿
      CHARACTERS
      JOINABLE_FIELDS = %i[pattern composition dependencies dependents].freeze

      def initialize(chiseids)
        @chiseids = chiseids
      end

      def self.read(chiseids)
        new(chiseids).read
      end

      def read
        load_characters
        resolver = JD::Kanjidep::DependencyResolver.resolve(@characters)
        @characters.each do |character|
          add_dependency_fields(character, resolver)
          update_joinable_fields(character)
        end
      end

      private

      def load_characters
        @characters = @chiseids.map do |row|
          pattern = row["ids"].chars
            .select { |character| PREFIXES.include?(character) }
          composition = split_ids(clean_ids(row["ids"]))
            .reject { |character| character == row["character"] }
          {
            character: row["character"],
            pattern: pattern,
            composition: composition
          }
        end
      end

      def clean_ids(ids)
        ids
          .then { |i| keep_only_first_sequence(i) }
          .then { |i| remove_text_in_brackets(i) }
          .then { |i| remove_spaces(i) }
          .then { |i| remove_prefixes(i) }
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
        ids
          .chars
          .reject { |character| PREFIXES.include?(character) }
          .join
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

      def add_dependency_fields(character, resolver)
        dependencies = resolver.fetch_dependencies(character[:character])
        character[:dependencies] = dependencies

        dependents = resolver.fetch_dependents(character[:character])
        character[:dependents] = dependents
      end

      def update_joinable_fields(character)
        JOINABLE_FIELDS.each do |field|
          character[field] = character[field].join(" ")
        end
      end
    end
  end
end
