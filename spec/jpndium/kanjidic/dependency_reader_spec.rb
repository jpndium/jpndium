# frozen_string_literal: true

RSpec.describe Jpndium::Kanjidic::DependencyReader do
  let(:kanjidic_kanji) { %w[A B D E G] }
  let(:kanjidic) do
    kanjidic_kanji.map do |kanji|
      { "literal" => kanji }
    end
  end
  let(:chiseidsdep) do
    [
      {
        "character" => "A",
        "pattern" => "(pattern)",
        "composition" => "B C",
        "dependencies" => "B C D",
        "dependents" => "E F"
      },
      {
        "character" => "C",
        "pattern" => "(pattern)",
        "composition" => nil,
        "dependencies" => nil,
        "dependents" => nil
      }
    ]
  end
  let(:kanjidicdep) { described_class.read(kanjidic, chiseidsdep) }
  let(:expected) do
    [
      {
        character: "A",
        pattern: "(pattern)",
        composition: "B",
        dependencies: "B D",
        dependents: "E"
      }
    ]
  end

  describe "#read" do
    it "keeps kanji from kanjidic" do
      expect(kanjidicdep).to match_array(expected)
    end
  end
end
