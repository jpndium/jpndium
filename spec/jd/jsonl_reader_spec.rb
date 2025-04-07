# frozen_string_literal: true

require "jd/jsonl_reader"

RSpec.describe JD::JsonlReader do
  subject(:reader) { described_class.new }

  describe "#read_file" do
    path = "hello.jsonl"

    lines = [
      '{"hello": true}',
      '{"goodbye": false}'
    ]

    expected = [
      { "hello" => true },
      { "goodbye" => false }
    ]

    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path).and_yield(lines)
    end

    it "parses each JSON line" do
      expect(reader.read_file(path)).to match_array(expected)
    end
  end
end
