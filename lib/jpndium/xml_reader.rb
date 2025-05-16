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

    def read_each(path)
      File.open(path) do |file|
        Nokogiri::XML(file, nil, "UTF-8")
          .search(@element_name)
          .each { |e| yield read_element(e) }
      end
    end

    def read_element(_element)
      raise NoMethodError, "#{self.class} must implement #{__method__}"
    end
  end
end
