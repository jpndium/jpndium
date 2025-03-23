# frozen_string_literal: true

require "jd/chiseids/reader"

RSpec.describe JD::Chiseids::Reader do
  row = { codepoint: "U+6CC9", character: "泉", ids: "⿱白水" }
  line = "#{row.values.join("\t")}\n"

  let(:reader) { described_class.new }

  describe "#read_line" do
    it "reads a line" do
      expect(reader.read_line(line)).to eq(row)
    end

    context "when the line is a comment" do
      it "returns nil" do
        expect(reader.read_line(";; this is a comment")).to be_nil
      end
    end

    context "when there are fewer than three values" do
      line = "#{row.values[0...-1].join("\t")}\n"

      it "reads only the first three values" do
        expect(reader.read_line(line)).to eq(row)
      end
    end

    context "when there are more than three values" do
      line = "#{[*row.values, 'foobar'].join("\t")}\n"

      it "reads only the first three values" do
        expect(reader.read_line(line)).to eq(row)
      end
    end
  end
end
