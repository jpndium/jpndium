# frozen_string_literal: true

module Jpndium
  module Chiseids
    # Reads chiseids jsonl files and derives dependency information for each
    # Ideographic Description Sequence (IDS).
    class DependencyReader
      PREFIXES = <<~CHARACTERS.split.freeze
        ⿰ ⿱ ⿲ ⿳ ⿴ ⿵ ⿶ ⿷ ⿼ ⿸ ⿹ ⿺ ⿽ ⿻ ⿾ ⿿
      CHARACTERS

      def initialize(chiseids)
        @chiseids = chiseids
      end

      def self.read(chiseids, &)
        new(chiseids).read(&)
      end

      def read(&)
        return read_all unless block_given?

        read_each(&)
      end

      private

      def read_all
        [].tap { |r| read_each(&r.method(:append)) }
      end

      def read_each(&)
        @chiseids.each { |row| yield read_row(row) }
      end

      def read_row(row)
        character = row["character"]
        pattern = row["ids"].chars.select { |c| PREFIXES.include?(c) }
        resolution = resolutions[character]
        {
          character: character,
          pattern: pattern.join(" "),
          composition: compositions[character].join(" "),
          dependencies: resolution[:dependencies].join(" "),
          dependents: resolution[:dependents].join(" ")
        }
      end

      def resolutions
        @resolutions ||= Jpndium::DependencyResolver
          .resolve(compositions)
          .to_h { |resolution| [resolution[:value], resolution] }
      end

      def compositions
        @compositions ||= @chiseids
          .to_h do |row|
            composition = split_ids(clean_ids(row["ids"]))
              .reject { |character| character == row["character"] }
            [row["character"], composition]
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
    end
  end
end
