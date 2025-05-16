# frozen_string_literal: true

RSpec.describe Jpndium::XmlReader do
  path = "path"
  file = "file"
  elements = [1, 2, 3]
  value = "value"

  let(:reader) do
    described_class.new.tap do |reader|
      allow(reader).to receive(:read_element).and_return(value)
    end
  end
  let(:document) do
    double.tap do |document|
      allow(document).to receive(:search).and_return(elements)
    end
  end

  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(path).and_yield(file)

    allow(Nokogiri)
      .to receive(:XML).with(file, nil, "UTF-8").and_return(document)
  end

  describe "#read_each" do
    it "yields each read element", :aggregate_failures do
      reader.read(path) { |v| expect(v).to eq(value) }
      elements.each do |element|
        expect(reader).to have_received(:read_element).with(element)
      end
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
