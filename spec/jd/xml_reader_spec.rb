# frozen_string_literal: true

require "jd/xml_reader"

RSpec.describe JD::XmlReader do
  path = "path"
  content = "content"
  elements = [1, 2, 3]
  value = "value"
  values = [value, value, value]
  block = ->(_) {}

  let(:reader) do
    reader = described_class.new
    allow(reader).to receive(:read_one).and_return(value)
    reader
  end

  let(:document) do
    document = double
    allow(document).to receive(:search).and_return(elements)
    document
  end

  def expect_elements_read(reader, elements)
    elements.each do |element|
      expect(reader).to have_received(:read_one).with(element)
    end
  end

  describe "#read_file" do
    before do
      allow(File).to receive(:open).with(path).and_yield(content)
      allow(Nokogiri).to receive(:XML).with(content).and_return(document)
      allow(reader).to receive(:read).and_call_original
    end

    it "reads the file" do
      reader.read_file(path, &block)
      expect(reader).to have_received(:read).with(content, &block)
    end
  end

  describe "#read" do
    before do
      allow(Nokogiri).to receive(:XML).with(content).and_return(document)
      allow(reader).to receive(:read_document).and_call_original
    end

    it "reads the contents" do
      reader.read(content, &block)
      expect(reader).to have_received(:read_document).with(document, &block)
    end
  end

  describe "#read_document" do
    before { allow(reader).to receive(:read_elements).and_call_original }

    it "reads the document" do
      reader.read_document(document, &block)
      expect(reader).to have_received(:read_elements).with(elements, &block)
    end
  end

  describe "#read_elements" do
    before do
      allow(reader).to receive(:read_each).and_call_original
      allow(reader).to receive(:read_all).and_call_original
    end

    context "when a block is passed" do
      it "yields each read element to the block", :aggregate_failures do
        reader.read_elements(elements, &block)
        expect(reader).to have_received(:read_each).with(elements, &block)
        expect(reader).not_to have_received(:read_all)
      end
    end

    context "when a block is not passed" do
      it "reads all elements", :aggregate_failures do
        expect(reader.read_elements(elements)).to match_array(values)
        expect(reader).not_to have_received(:read_each)
        expect(reader).to have_received(:read_all).with(elements)
      end
    end
  end

  describe "#read_each" do
    it "reads each element" do
      reader.read_each(elements) { |v| expect(v).to eq(value) }
      expect_elements_read(reader, elements)
    end
  end

  describe "#read_all" do
    it "reads every element" do
      expect(reader.read_all(elements)).to match_array(values)
      expect_elements_read(reader, elements)
    end
  end

  describe "#read_one" do
    it "must be implemented" do
      expect { described_class.new.read_one(nil) }
        .to raise_exception(NoMethodError)
    end
  end
end
