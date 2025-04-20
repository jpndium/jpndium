# frozen_string_literal: true

require "jd/jmnedictpri/reader"

RSpec.describe JD::Jmnedictpri::Reader do
  describe ".read" do
    let(:actual) { described_class.read_file("spec/jd/jmnedict/jmnedict.xml") }
    let(:expected) do
      entries = JSON.load_file(
        "spec/jd/jmnedict/jmnedict.json",
        { symbolize_names: true }
      )
      [entries[0]]
    end

    it "returns priority entries" do
      expected.each_with_index { |e, i| expect(actual[i]).to eq(e) }
    end
  end
end
