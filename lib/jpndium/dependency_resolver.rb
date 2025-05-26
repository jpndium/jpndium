# frozen_string_literal: true

module Jpndium
  # Resolves dependency information.
  class DependencyResolver
    def initialize(*, **); end

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

    def resolve_each
      raise NoMethodError, "#{self.class} must implement #{__method__}"
    end
  end
end
