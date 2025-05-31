# frozen_string_literal: true

RSpec.describe Jpndium::Jmnedict::DependencyResolver do
  jmnedict = [
    {
      "ent_seq" => 1,
      "k_ele" => [
        { "keb" => "AB" },
        { "keb" => "C" }
      ]
    },
    {
      "ent_seq" => 2,
      "k_ele" => [
        { "keb" => "D" },
        { "keb" => "E" }
      ]
    },
    { "ent_seq" => 3 }
  ]
  kanjidic = [
    { "literal" => "A" },
    { "literal" => "B" },
    { "literal" => "C" }
  ]
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
    }
  ]
  expected = [
    {
      ent_seq: 1,
      k_ele: [
        {
          keb: "AB",
          composition: "A B",
          dependencies: "A B",
          kanji: "A B"
        },
        {
          keb: "C",
          composition: "D E",
          dependencies: "E D",
          kanji: "C"
        }
      ]
    },
    {
      ent_seq: 2,
      k_ele: [
        {
          keb: "D",
          composition: "E",
          dependencies: "E",
          dependents: "C E"
        },
        {
          keb: "E",
          composition: "D",
          dependencies: "D",
          dependents: "C D"
        }
      ]
    },
    { ent_seq: 3 }
  ]

  describe "#resolve" do
    before do
      tokenizer = instance_double(Jpndium::Tokenizer)
      allow(tokenizer).to receive(:tokenize)
      allow(tokenizer).to receive_and_yield(:read, tokens)
      allow(Jpndium::Tokenizer).to receive(:open).and_yield(tokenizer)
    end

    it "resolves dependencies for each entry" do
      actual = described_class.resolve(jmnedict, kanjidic)
      expect(actual).to match_array(expected)
    end
  end
end
