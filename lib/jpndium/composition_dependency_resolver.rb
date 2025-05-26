# frozen_string_literal: true

module Jpndium
  # Resolves dependency information for compositions.
  class CompositionDependencyResolver < Jpndium::DependencyResolver
    attr_reader :compositions

    def initialize(compositions)
      super()
      @compositions = compositions
    end

    protected

    def resolve_each
      values.each { |value| yield fetch_resolution(value) }
    end

    def fetch_resolution(value)
      {
        value: value,
        composition: fetch_composition(value),
        dependencies: fetch_dependencies(value),
        dependents: fetch_dependents(value)&.sort
      }.compact
    end

    def values
      compositions.keys
    end

    def fetch_composition(value)
      compositions.fetch(value, nil).tap { |c| return nil if c&.empty? }
    end

    def fetch_dependencies(value)
      dependencies.fetch(value, nil)
    end

    def dependencies
      @dependencies ||= values.to_h { |v| [v, resolve_dependencies(v)] }
    end

    def resolve_dependencies(value, seen = nil)
      seen = (seen || []).tap { |s| s << value }

      (compositions.fetch(value, nil) || [])
        .map do |component|
          next [] if seen.include?(component)

          [*resolve_dependencies(component, seen), component]
        end
        .reduce(:+)
        &.uniq
    end

    def fetch_dependents(value)
      dependents.fetch(value, nil)
    end

    def dependents
      @dependents ||= {}.tap do |dependents|
        values.each { |v| resolve_dependents(dependents, v) }
      end
    end

    def resolve_dependents(dependents, value)
      dependencies.fetch(value, nil)&.each do |dependency|
        (dependents[dependency] ||= []).then { |d| d << value }
      end
    end
  end
end
