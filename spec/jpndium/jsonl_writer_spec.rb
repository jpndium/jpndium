# frozen_string_literal: true

RSpec.describe Jpndium::JsonlWriter do
  let(:path) { "path" }
  let(:file) do
    double.tap do |file|
      allow(file).to receive(:close)
      allow(file).to receive(:write)
    end
  end
  let(:writer) { described_class.new(path) }

  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(path, "w").and_return(file)
  end

  describe "#write" do
    let(:value) do
      { foo: 1, bar: 2 }
    end
    let(:json) { JSON.dump(value) }

    it "writes JSON values to the file" do
      writer.open.write(value)
      expect(file).to have_received(:write).with(json, "\n")
    end

    it "returns self" do
      expect(writer.open.write(value)).to eq(writer)
    end
  end

  describe "#sequence" do
    before do
      allow(File).to receive(:open)
        .with("#{path}/001.jsonl", "w")
        .and_return(file)
    end

    it "writes to jsonl sequence files" do
      writer.sequence { writer.write("test") }
      expect(File).to have_received(:open).with("#{path}/001.jsonl", "w")
    end
  end
end
