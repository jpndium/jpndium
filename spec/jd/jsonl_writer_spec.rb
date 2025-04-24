# frozen_string_literal: true

RSpec.describe JD::JsonlWriter do
  let(:path) { "hello.jsonl" }
  let(:file) do
    file = double
    allow(file).to receive(:close)
    allow(file).to receive(:write)
    file
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
end
