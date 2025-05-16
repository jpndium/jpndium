# frozen_string_literal: true

RSpec.describe Jpndium::Kanjidic::Reader do
  describe ".read" do
    let(:actual) do
      described_class.read("spec/jpndium/kanjidic/kanjidic.xml")
    end
    let(:expected) do
      JSON.load_file(
        "spec/jpndium/kanjidic/kanjidic.json",
        { symbolize_names: true }
      )
    end

    it "returns characters" do
      expected.each_with_index { |e, i| expect(actual[i]).to eq(e) }
    end
  end
end
