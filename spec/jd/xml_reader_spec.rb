# frozen_string_literal: true

require "jd/xml_reader"

RSpec.describe JD::XmlReader do
  stream = "stream"
  elements = [1, 2, 3]
  value = "value"

  let(:reader) do
    reader = described_class.new
    allow(reader).to receive(:read_element).and_return(value)
    reader
  end

  let(:document) do
    document = double
    allow(document).to receive(:search).and_return(elements)
    document
  end

  before do
    allow(Nokogiri).to receive(:XML).with(stream).and_return(document)
  end

  describe "#read_each" do
    it "yields each read element", :aggregate_failures do
      reader.read_each(stream) { |v| expect(v).to eq(value) }
      elements.each do |element|
        expect(reader).to have_received(:read_element).with(element)
      end
    end
  end

  describe "#read_line" do
    it "is not defined" do
      expect(described_class.new.respond_to?(:read_line)).to be false
    end
  end

  describe "#read_element" do
    it "must be implemented" do
      expected_message = "JD::XmlReader must implement read_element"
      expect { described_class.new.read_element(nil) }
        .to raise_error(NoMethodError, expected_message)
    end
  end
end
