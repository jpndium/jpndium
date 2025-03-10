# frozen_string_literal: true

require "nokogiri"
require_relative "xml_helpers"

module JD
  # Reads elements from an XML file.
  class XmlReader
    include JD::XmlHelpers

    def initialize
      @element_name = nil
    end

    def read_file(path, &)
      File.open(path) { |file| read(file, &) }
    end

    def read(content, &)
      read_document(Nokogiri::XML(content), &)
    end

    def read_document(document, &)
      read_elements(document.search(@element_name), &)
    end

    def read_elements(elements, &)
      return read_each(elements, &) if block_given?

      read_all(elements)
    end

    def read_each(elements)
      elements.each { |element| yield read_one(element) }
    end

    def read_all(elements)
      elements.map { |element| read_one(element) }
    end

    def read_one(_element)
      raise NoMethodError, "#{self.class} must implement #{__method__}"
    end
  end
end
