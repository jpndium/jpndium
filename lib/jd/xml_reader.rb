# frozen_string_literal: true

require "nokogiri"
require_relative "file_reader"
require_relative "xml_helpers"

module JD
  # Reads elements from an XML file.
  class XmlReader < JD::FileReader
    include JD::XmlHelpers

    def initialize
      super
      @element_name = nil
    end

    protected

    undef_method :read_line

    def read_element(_element)
      raise NoMethodError, "#{self.class} must implement #{__method__}"
    end

    private

    def read_each(stream)
      document = Nokogiri::XML(stream)
      elements = document.search(@element_name)
      elements.each { |element| yield read_element(element) }
    end
  end
end
