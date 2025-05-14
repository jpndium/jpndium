# frozen_string_literal: true

RSpec.describe Jpndium::DependencyResolver do
  let(:compositions) do
    {
      "A" => [],
      "B" => [],
      "C" => %w[A B]
    }
  end
  let(:resolver) { described_class.new(compositions) }

  describe ".resolve" do
    let(:instance) do
      double.tap { |i| allow(i).to receive(:resolve) }
    end

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it "forwards arguments to the constructor" do
      described_class.resolve(compositions)
      expect(described_class).to have_received(:new).with(compositions)
    end

    it "calls #resolve on the instance" do
      described_class.resolve(compositions)
      expect(instance).to have_received(:resolve)
    end
  end

  describe "#resolve" do
    let(:expected) do
      [
        {
          value: "A",
          composition: [],
          dependencies: [],
          dependents: %w[C]
        },
        {
          value: "B",
          composition: [],
          dependencies: [],
          dependents: %w[C]
        },
        {
          value: "C",
          composition: %w[A B],
          dependencies: %w[A B],
          dependents: []
        }
      ]
    end

    it "resolves dependency information" do
      expect(resolver.resolve).to match_array(expected)
    end

    context "when called multiple times" do
      it "returns the same result" do
        resolver.resolve
        expect(resolver.resolve).to match_array(expected)
      end
    end

    context "when passed a block" do
      it "yields each resolution to the block" do
        actual = [].tap { |a| resolver.resolve(&a.method(:append)) }
        expect(actual).to match_array(expected)
      end
    end

    context "when there is a cyclical dependency" do
      let(:compositions) do
        {
          "A" => [],
          "B" => [],
          "C" => %w[A B],
          "D" => %w[A F],
          "E" => %w[C D],
          "F" => %w[D E]
        }
      end
      let(:expected) do
        [
          {
            value: "A",
            composition: [],
            dependencies: [],
            dependents: %w[C D E F]
          },
          {
            value: "B",
            composition: [],
            dependencies: [],
            dependents: %w[C D E F]
          },
          {
            value: "C",
            composition: %w[A B],
            dependencies: %w[A B],
            dependents: %w[D E F]
          },
          {
            value: "D",
            composition: %w[A F],
            dependencies: %w[A B C E F],
            dependents: %w[E F]
          },
          {
            value: "E",
            composition: %w[C D],
            dependencies: %w[A B C F D],
            dependents: %w[D F]
          },
          {
            value: "F",
            composition: %w[D E],
            dependencies: %w[A D B C E],
            dependents: %w[D E]
          }
        ]
      end

      it "short-circuits the inifinite loop" do
        expect(resolver.resolve).to match_array(expected)
      end

      it "is order independent" do
        resolver = described_class.new(compositions.to_a.reverse.to_h)
        expect(resolver.resolve).to match_array(expected.reverse)
      end
    end
  end
end
