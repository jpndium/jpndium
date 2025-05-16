# frozen_string_literal: true

RSpec.describe Jpndium::JsonlReader do
  let(:reader) { described_class.new }

  describe "#read" do
    let(:path) { "hello.jsonl" }
    let(:lines) { ['{"hello": true}', '{"goodbye": false}'] }
    let(:expected) { [{ "hello" => true }, { "goodbye" => false }] }

    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path).and_yield(lines)
    end

    it "parses each JSON line" do
      expect(reader.read(path)).to match_array(expected)
    end
  end
end
