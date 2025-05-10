# frozen_string_literal: true

RSpec.describe Jpndium::FileReader do
  let(:path) { "path" }
  let(:lines) { Array.new(3, "line") }

  describe "#read_file" do
    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path).and_yield(lines)
    end

    context "when given a block" do
      it "yields each read line" do
        described_class
          .read_file(path) { |actual| expect(actual).to eq("line") }
      end
    end

    context "when not given a block" do
      it "returns all read lines" do
        expect(described_class.read_file(path)).to match_array(lines)
      end
    end
  end

  describe "#read" do
    context "when given a block" do
      it "yields each read line" do
        described_class.read(lines) { |actual| expect(actual).to eq("line") }
      end
    end

    context "when not given a block" do
      it "returns all read lines" do
        expect(described_class.read(lines)).to match_array(lines)
      end
    end
  end
end
