# frozen_string_literal: true

require "json"
require "jd/kanjidic/reader"

RSpec.describe JD::Kanjidic::Reader do
  describe ".read" do
    let(:actual) { described_class.read_file("spec/jd/kanjidic/kanjidic.xml") }
    let(:expected) do
      JSON.load_file(
        "spec/jd/kanjidic/kanjidic.json",
        { symbolize_names: true }
      )
    end

    it "returns characters" do
      expected.each_with_index do |element, i|
        expect(element).to eq(actual[i])
      end
    end
  end
end
