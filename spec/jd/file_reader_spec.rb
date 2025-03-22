# frozen_string_literal: true

require "jd/file_reader"

RSpec.describe JD::FileReader do
  path = "path"
  value = "value"
  values = Array.new(3, value)
  lines = Array.new(3, "line")

  let(:reader) do
    reader = described_class.new
    allow(reader).to receive(:read_line).and_return(value)
    reader
  end

  describe "#read_file" do
    before do
      allow(File).to receive(:open).with(path).and_yield(lines)
    end

    context "when given a block" do
      it "yields each read line" do
        reader.read_file(path) { |actual| expect(actual).to eq(value) }
      end
    end

    context "when not given a block" do
      it "returns all read lines" do
        expect(reader.read_file(path)).to match_array(values)
      end
    end
  end

  describe "#read" do
    context "when given a block" do
      it "yields each read line" do
        reader.read(lines) { |actual| expect(actual).to eq(value) }
      end
    end

    context "when not given a block" do
      it "returns all read lines" do
        expect(reader.read(lines)).to match_array(values)
      end
    end
  end

  describe "#read_all" do
    it "returns all read lines" do
      expect(reader.read_all(lines)).to match_array(values)
    end
  end

  describe "#read_each" do
    it "yields each read line" do
      reader.read_each(lines) { |actual| expect(actual).to eq(value) }
    end
  end

  describe "#read_line" do
    it "must be implemented" do
      expected_message = "JD::FileReader must implement read_line"
      expect { described_class.new.read_line(nil) }
        .to raise_error(NoMethodError, expected_message)
    end
  end
end
