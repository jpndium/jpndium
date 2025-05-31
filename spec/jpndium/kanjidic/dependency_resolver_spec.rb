# frozen_string_literal: true

RSpec.describe Jpndium::Kanjidic::DependencyResolver do
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
        "character" => "B",
        "pattern" => "(pattern)",
        "composition" => "Z",
        "dependencies" => "Z",
        "dependents" => "Z"
      },
      {
        "character" => "C",
        "pattern" => "(pattern)"
      },
      {
        "character" => "D",
        "pattern" => "(pattern)"
      }
    ]
  end
  let(:kanjidicdep) { described_class.resolve(kanjidic, chiseidsdep) }
  let(:expected) do
    [
      {
        literal: "A",
        pattern: "(pattern)",
        composition: "B",
        dependencies: "B D",
        dependents: "E"
      },
      {
        literal: "B",
        pattern: "(pattern)"
      },
      {
        literal: "D",
        pattern: "(pattern)"
      }
    ]
  end

  describe "#resolve" do
    it "keeps kanji from kanjidic" do
      expect(kanjidicdep).to match_array(expected)
    end
  end
end
