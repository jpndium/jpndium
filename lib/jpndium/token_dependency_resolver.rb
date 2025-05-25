# frozen_string_literal: true

module Jpndium
  # Resolves dependency information for token compositions.
  class TokenDependencyResolver < Jpndium::DependencyResolver
    def initialize(tokens, kanjidic)
      super
      @tokens = tokens
      @kanjidic = kanjidic
    end

    protected

    def resolve_each
      Jpndium::CompositionDependencyResolver
        .resolve(compositions) do |resolution|
          text = resolution.delete(:value)
          yield ({
            text:,
            **resolution,
            kanji: fetch_kanji(text)
          }).compact
        end
    end

    def compositions
      @compositions ||= {}.tap do |map|
        @tokens.each { |t| map[t["text"]] = fetch_composition(t) }
      end
    end

    def fetch_composition(token)
      return token["composition"].split if token.key?("composition")

      [token["dictionary_form"], token["normalized_form"]]
        .compact
        .uniq
        .reject { |v| v == token["text"] }
        .then { |c| c.empty? ? nil : c }
    end

    def fetch_kanji(value)
      return nil unless kanjidic_kanji

      value.chars
        .select { |c| kanjidic_kanji.include?(c) }
        .then { |k| k.empty? ? nil : k }
    end

    def kanjidic_kanji
      @kanjidic_kanji ||= @kanjidic&.to_set { |r| r["literal"] }
    end
  end
end
