# frozen_string_literal: true

require "jd/chiseids/reader"

RSpec.describe JD::Chiseids::Reader do
  let(:row) do
    { codepoint: "U+6CC9", character: "泉", ids: "⿱白水" }
  end
  let(:rows) { [row] }
  let(:line) { "#{row.values.join("\t")}\n" }
  let(:lines) { [line] }
  let(:reader) { described_class.new }

  describe "#read_line" do
    it "reads a line" do
      expect(reader.read_line(line)).to eq(row)
    end

    context "when the line is a comment" do
      let(:line) { ";; this is a comment" }

      it "returns nil" do
        expect(reader.read_line(";; this is a comment")).to be_nil
      end
    end

    context "when there are fewer than three values" do
      let(:line) { "#{row.values[0...-1].join("\t")}\n" }
      let(:row) do
        { codepoint: "U+6CC9", character: "泉", ids: nil }
      end

      it "reads only the first three values" do
        expect(reader.read_line(line)).to eq(row)
      end
    end

    context "when there are more than three values" do
      let(:line) { "#{[*row.values, 'foobar'].join("\t")}\n" }

      it "reads only the first three values" do
        expect(reader.read_line(line)).to eq(row)
      end
    end
  end
end
