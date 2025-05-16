# frozen_string_literal: true

RSpec.describe Jpndium::JsonlSequenceWriter do
  let(:directory_path) { "foobar" }
  let(:path) { "#{directory_path}/001.jsonl" }
  let(:file) do
    file = double
    allow(file).to receive(:close)
    allow(file).to receive(:write)
    file
  end
  let(:writer) { described_class.new(directory_path) }

  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(path, "w").and_return(file)
  end

  describe "#write" do
    it "writes JSON values to the file" do
      value = { foo: 1, bar: 2 }
      writer.open.write(value)
      expect(file).to have_received(:write).with(JSON.dump(value), "\n")
    end

    it "returns self" do
      expect(writer.open.write({})).to eq(writer)
    end
  end
end
