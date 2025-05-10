# frozen_string_literal: true

module Jpndium
  # Reads elements from an XML file.
  class XmlReader < Jpndium::FileReader
    include Jpndium::XmlHelpers

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
      document = Nokogiri::XML(stream, nil, "UTF-8")
      elements = document.search(@element_name)
      elements.each { |element| yield read_element(element) }
    end
  end
end
