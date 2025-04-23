# frozen_string_literal: true

RSpec.describe JD::FileReader do
  let(:path) { "path" }
  let(:value) { "value" }
  let(:values) { Array.new(3, value) }
  let(:lines) { Array.new(3, "line") }

  def stub_reader
    reader = described_class.new
    allow(reader).to receive(:read_line).and_return(value)
    allow(described_class).to receive(:new).and_return(reader)
  end

  describe "#read_file" do
    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path).and_yield(lines)
      stub_reader
    end

    context "when given a block" do
      it "yields each read line" do
        described_class.read_file(path) { |actual| expect(actual).to eq(value) }
      end
    end

    context "when not given a block" do
      it "returns all read lines" do
        expect(described_class.read_file(path)).to match_array(values)
      end
    end
  end

  describe "#read" do
    before { stub_reader }

    context "when given a block" do
      it "yields each read line" do
        described_class.read(lines) { |actual| expect(actual).to eq(value) }
      end
    end

    context "when not given a block" do
      it "returns all read lines" do
        expect(described_class.read(lines)).to match_array(values)
      end
    end
  end

  describe "#read_line" do
    it "must be implemented" do
      expected_message = "JD::FileReader must implement read_line"
      expect { described_class.new.send(:read_line, nil) }
        .to raise_error(NoMethodError, expected_message)
    end
  end
end
