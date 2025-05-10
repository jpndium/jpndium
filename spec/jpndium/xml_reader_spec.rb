# frozen_string_literal: true

RSpec.describe Jpndium::XmlReader do
  let(:stream) { "stream" }
  let(:elements) { [1, 2, 3] }
  let(:value) { "value" }

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
    allow(Nokogiri)
      .to receive(:XML).with(stream, nil, "UTF-8").and_return(document)
  end

  describe "#read_each" do
    it "yields each read element", :aggregate_failures do
      reader.read(stream) { |v| expect(v).to eq(value) }
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
      expected_message = "#{described_class.name} must implement read_element"
      expect { described_class.new.send(:read_element, nil) }
        .to raise_error(NoMethodError, expected_message)
    end
  end
end
