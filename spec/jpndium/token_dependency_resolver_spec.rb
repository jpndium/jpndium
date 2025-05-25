# frozen_string_literal: true

RSpec.describe Jpndium::TokenDependencyResolver do
  tokens = [
    { "text" => "AB", "composition" => "A B" },
    {
      "text" => "C",
      "dictionary_form" => "D",
      "normalized_form" => "E"
    },
    {
      "text" => "D",
      "dictionary_form" => "D",
      "normalized_form" => "E"
    },
    {
      "text" => "E",
      "dictionary_form" => "D",
      "normalized_form" => "E"
    },
    {
      "text" => "F",
      "dictionary_form" => "F",
      "normalized_form" => "F"
    }
  ]
  kanjidic = [
    { "literal" => "A" },
    { "literal" => "B" },
    { "literal" => "C" }
  ]
  expected = [
    {
      text: "AB",
      composition: %w[A B],
      dependencies: %w[A B],
      kanji: %w[A B]
    },
    {
      text: "C",
      composition: %w[D E],
      dependencies: %w[E D],
      kanji: ["C"]
    },
    {
      text: "D",
      composition: ["E"],
      dependencies: ["E"],
      dependents: %w[C E]
    },
    {
      text: "E",
      composition: ["D"],
      dependencies: ["D"],
      dependents: %w[C D]
    },
    { text: "F" }
  ]

  describe "#resolve" do
    it "resolves dependencies for each token" do
      expect(described_class.resolve(tokens, kanjidic)).to match_array(expected)
    end
  end
end
