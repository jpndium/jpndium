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
            k_ele: entry["k_ele"]&.map do |k_ele|
              { keb: k_ele["keb"], **resolutions[k_ele["keb"]] }
            end
          }).compact
        end
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
    end
  end
end
