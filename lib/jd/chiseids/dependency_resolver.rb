# frozen_string_literal: true

module JD
  module Chiseids
    # Determines kanji dependencies and dependents.
    class DependencyResolver
      attr_reader :dependencies, :dependents

      def initialize(characters)
        @characters = characters.each_with_object({}) do |character, map|
          map[character[:character]] = character
        end
      end

      def self.resolve(characters)
        new(characters).resolve
      end

      def fetch_dependencies(character)
        fetch_or_empty_array(@dependencies, character)
      end

      def fetch_dependents(character)
        fetch_or_empty_array(@dependents, character)
      end

      def resolve
        resolve_dependencies
        resolve_dependents
        self
      end

      private

      def resolve_dependencies
        @dependencies = {}
        @characters.each_value do |character|
          resolve_character_dependencies(character)
        end
      end

      def resolve_character_dependencies(character)
        components = resolve_components(character[:character])
        @dependencies[character[:character]] = components
      end

      def resolve_components(character, ignore = nil)
        ignore = [*(ignore || []), character]

        composition = @characters
          .fetch(character, nil)
          &.fetch(:composition, nil)
          .then { |value| value || [] }

        composition
          .map do |component|
            next [] if ignore.include?(component)

            [*resolve_components(component, ignore), component]
          end
          .reduce(:+)
          .then { |value| value || [] }
          .uniq
      end

      def resolve_dependents
        @dependents = {}
        @characters.each_value do |character|
          resolve_character_dependents(character)
        end
      end

      def resolve_character_dependents(character)
        fetch_dependencies(character[:character]).each do |dependency|
          @dependents[dependency] ||= []
          @dependents[dependency] << character[:character]
        end
      end

      def fetch_or_empty_array(hash, key)
        hash.fetch(key, nil) || []
      end
    end
  end
end
