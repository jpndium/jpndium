# frozen_string_literal: true

module Jpndium
  # Resolves dependency information for values with compositions.
  class DependencyResolver
    def initialize(compositions)
      @compositions = compositions
    end

    def self.resolve(*, **, &)
      new(*, **).resolve(&)
    end

    def resolve(&)
      return resolve_all unless block_given?

      resolve_each(&)
    end

    protected

    def resolve_all
      [].tap { |r| resolve_each(&r.method(:append)) }
    end

    def resolve_each(&)
      values.each { |value| yield fetch_resolution(value) }
    end

    def fetch_resolution(value)
      {
        value: value,
        composition: fetch_composition(value),
        dependencies: fetch_dependencies(value),
        dependents: fetch_dependents(value).sort
      }
    end

    def fetch_composition(value)
      fetch_or_empty_array(@compositions, value)
    end

    def fetch_dependencies(value)
      fetch_or_empty_array(dependencies, value)
    end

    def dependencies
      @dependencies ||= values.to_h { |v| [v, resolve_dependencies(v)] }
    end

    def resolve_dependencies(value, seen = nil)
      seen = (seen || []).tap { |s| s << value }

      fetch_or_empty_array(@compositions, value)
        .map do |component|
          next [] if seen.include?(component)

          [*resolve_dependencies(component, seen), component]
        end
        .reduce(:+)
        .then { |d| d || [] }
        .uniq
    end

    def fetch_dependents(value)
      fetch_or_empty_array(dependents, value)
    end

    def dependents
      @dependents ||= {}.tap do |dependents|
        values.each { |v| resolve_dependents(dependents, v) }
      end
    end

    def resolve_dependents(dependents, value)
      fetch_dependencies(value).each do |dependency|
        (dependents[dependency] ||= []).then { |d| d << value }
      end
    end

    def values
      @compositions.keys
    end

    def fetch_or_empty_array(hash, key)
      hash.fetch(key, nil) || []
    end
  end
end
