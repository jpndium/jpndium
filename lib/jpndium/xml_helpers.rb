# frozen_string_literal: true

module JD
  # Helper methods for reading XML elements.
  module XmlHelpers
    protected

    def find_first_content(element, path)
      compact_content(find_first(element, path))
    end

    def find_first(element, path)
      element&.search(path)&.first
    end

    def find_content(element, path)
      compact(find_map(element, path) { |e| compact_content(e) })
    end

    def find_map(element, path, &)
      compact(element&.search(path)&.map(&))
    end

    def compact_content(element)
      compact(element&.inner_html&.strip)
    end

    def compact(value)
      value = value.compact if value.respond_to?(:compact)
      return nil if value.nil? || value.empty?

      value
    end
  end
end
