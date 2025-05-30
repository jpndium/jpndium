# frozen_string_literal: true

module Jpndium
  module Jmdict
    # Resolves dependendency information for JMdict entries.
    class DependencyResolver < Jpndium::DependencyResolver
      def initialize(jmdict, kanjidic)
        super
        @jmdict = jmdict
        @kanjidic = kanjidic
      end

      protected

      def resolve_each
        @jmdict.each do |entry|
          yield ({
            ent_seq: entry["ent_seq"],
            k_ele: entry["k_ele"]&.map(&method(:fetch_resolution))
          }).compact
        end
      end

      def fetch_resolution(k_ele)
        resolution = resolutions[k_ele["keb"]] || {}
        {
          keb: k_ele["keb"],
          composition: list_string(resolution[:composition]),
          dependencies: list_string(resolution[:dependencies]),
          dependents: list_string(resolution[:dependents]),
          kanji: list_string(resolution[:kanji])
        }.compact
      end

      def resolutions
        @resolutions ||= {}.tap do |resolutions|
          Jpndium::TokenDependencyResolver
            .resolve(tokens, @kanjidic) do |resolution|
              text = resolution.delete(:text)
              resolutions[text] = resolution
            end
        end
      end

      def tokens
        @tokens ||= [].tap do |tokens|
          Jpndium::Tokenizer.open(unique: true) do |tokenizer|
            tokenizer.read(&tokens.method(:append))

            @jmdict.each do |row|
              row["k_ele"]&.each { |k| tokenizer.tokenize(k["keb"]) }
            end
          end
        end
      end

      def list_string(value)
        return nil if value.nil? || value.empty?

        value.join(" ")
      end
    end
  end
end
