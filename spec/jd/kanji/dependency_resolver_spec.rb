# frozen_string_literal: true

RSpec.describe JD::Kanji::DependencyResolver do
  let(:characters) do
    [
      { character: "A", composition: [] },
      { character: "B", composition: [] },
      { character: "C", composition: %w[A B] }
    ]
  end
  let(:resolver) { described_class.resolve(characters) }

  describe ".resolve" do
    let(:instance) do
      instance = described_class.new(characters)
      allow(instance).to receive(:resolve).and_call_original
      instance
    end

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it "returns the instantiated instance" do
      expect(described_class.resolve([])).to eq(instance)
    end

    it "calls #resolve on the instance" do
      described_class.resolve([])
      expect(instance).to have_received(:resolve)
    end
  end

  describe "#fetch_dependencies" do
    it "returns the character's dependencies" do
      expect(resolver.fetch_dependencies("C")).to match_array(%w[A B])
    end

    context "when there are no dependencies for the character" do
      it "returns an empty array" do
        expect(resolver.fetch_dependencies("Z")).to be_empty
      end
    end
  end

  describe "#fetch_dependents" do
    it "returns the character's dependencies" do
      expect(resolver.fetch_dependents("A")).to contain_exactly("C")
    end

    context "when there are no dependencies for the character" do
      it "returns an empty array" do
        expect(resolver.fetch_dependents("Z")).to be_empty
      end
    end
  end

  describe "#resolve" do
    let(:expected) do
      {
        "A" => [],
        "B" => [],
        "C" => %w[A B]
      }
    end

    it "resolves dependencies" do
      expect(resolver.dependencies).to include(expected)
    end

    context "when there is a cyclical dependency" do
      let(:characters) do
        [
          { character: "A", composition: [] },
          { character: "B", composition: [] },
          { character: "C", composition: %w[A B] },
          { character: "D", composition: %w[A F] },
          { character: "E", composition: %w[C D] },
          { character: "F", composition: %w[D E] }
        ]
      end
      let(:expected) do
        {
          "A" => [],
          "B" => [],
          "C" => %w[A B],
          "D" => %w[A B C E F],
          "E" => %w[A B C F D],
          "F" => %w[A D B C E]
        }
      end

      it "short-circuits the inifinite loop" do
        expect(resolver.dependencies).to include(expected)
      end

      it "is order independent" do
        resolver = described_class.resolve(characters.reverse)
        expect(resolver.dependencies).to include(expected)
      end
    end
  end
end
