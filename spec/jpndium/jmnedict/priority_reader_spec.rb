# frozen_string_literal: true

RSpec.describe Jpndium::Jmnedict::PriorityReader do
  describe ".read" do
    let(:entries) { JSON.load_file("spec/jpndium/jmnedict/jmnedict.json") }
    let(:lines) { entries.map(&JSON.method(:dump)) }
    let(:actual) { described_class.read("data") }
    let(:expected) { [entries[0]] }

    before do
      allow(Dir).to receive(:glob).and_yield("data/001.json")
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with("data/001.json").and_yield(lines)
    end

    it "returns priority entries" do
      expected.each_with_index { |e, i| expect(actual[i]).to eq(e) }
    end
  end
end
