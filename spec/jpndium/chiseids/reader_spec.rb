# frozen_string_literal: true

RSpec.describe Jpndium::Chiseids::Reader do
  path = "path"

  let(:reader) { described_class.new }
  let(:rows) do
    [{ codepoint: "U+6CC9", character: "泉", ids: "⿱白水" }]
  end
  let(:file) do
    ["#{rows[0].values.join("\t")}\n"]
  end

  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(path).and_yield(file)
  end

  describe "#read_line" do
    it "reads a line" do
      expect(reader.read(path)).to match_array(rows)
    end

    context "when the line is a comment" do
      let(:file) do
        [";; this is a comment"]
      end

      it "ignores the line" do
        expect(reader.read(path)).to be_empty
      end
    end

    context "when there are fewer than three values" do
      let(:rows) do
        [{ codepoint: "U+6CC9", character: "泉", ids: nil }]
      end
      let(:file) do
        ["#{rows[0].values[0...-1].join("\t")}\n"]
      end

      it "reads only the first three values" do
        expect(reader.read(path)).to match_array(rows)
      end
    end

    context "when there are more than three values" do
      let(:file) do
        ["#{[*rows[0].values, 'foobar'].join("\t")}\n"]
      end

      it "reads only the first three values" do
        expect(reader.read(path)).to match_array(rows)
      end
    end
  end
end
