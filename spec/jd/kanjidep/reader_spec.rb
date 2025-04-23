# frozen_string_literal: true

RSpec.describe JD::Kanjidep::Reader do
  let(:chiseids) do
    [{ character: "A", ids: "⿰火水⿱土風" }]
  end
  let(:resolver) do
    resolver = double
    allow(resolver)
      .to receive_messages(
        resolve: nil,
        fetch_dependencies: ["dependencies"],
        fetch_dependents: ["dependents"]
      )
    resolver
  end
  let(:kanjidep) do
    described_class
      .read(JSON.parse(JSON.dump(chiseids)))
      .each_with_object({}) do |character, hash|
        hash[character[:character]] = character
      end
  end

  before do
    allow(JD::Kanjidep::DependencyResolver)
      .to receive(:resolve)
      .and_return(resolver)
  end

  describe "#read" do
    let(:chiseids) do
      [{ character: "A", ids: "⿰火水⿱土風" }]
    end

    it "sets the pattern to the prefix characters from the IDS" do
      expect(kanjidep["A"][:pattern]).to eq("⿰ ⿱")
    end

    context "when the IDS has no prefix characters" do
      let(:chiseids) do
        [{ character: "A", ids: "火水" }]
      end

      it "sets the pattern to an empty array" do
        expect(kanjidep["A"][:pattern]).to eq("")
      end
    end

    context "when the IDS has a codepoint between & and ;" do
      let(:chiseids) do
        [{ character: "A", ids: "⿰火&ABC-123A;⿱&DEF-456B;風" }]
      end

      it "reads the codepoint as one character" do
        expect(kanjidep["A"][:composition])
          .to eq("火 &ABC-123A; &DEF-456B; 風")
      end
    end

    context "when the IDS has text in square brackets" do
      let(:chiseids) do
        [
          { character: "A", ids: "⿱鄉香[T]" },
          { character: "B", ids: "⿱鄉香[ABC]" },
          { character: "C", ids: "⿱[A]鄉[BC]香[DEF]" }
        ]
      end

      it "ignores a bracketed character" do
        expect(kanjidep["A"][:composition]).to eq("鄉 香")
      end

      it "ignores bracketed text" do
        expect(kanjidep["B"][:composition]).to eq("鄉 香")
      end

      it "ignores multiple bracketed text instances" do
        expect(kanjidep["C"][:composition]).to eq("鄉 香")
      end
    end

    context "when the IDS has multiple sequences" do
      let(:chiseids) do
        [
          { character: "A", ids: "⿰开龍 / ⿰幵龍" },
          { character: "B", ids: "⿰开龍 / ⿰幵龍 / ⿰幵龍" }
        ]
      end

      it "ignores a secondary sequence" do
        expect(kanjidep["A"][:composition]).to eq("开 龍")
      end

      it "ignores all additional sequences" do
        expect(kanjidep["B"][:composition]).to eq("开 龍")
      end
    end

    context "when the IDS has spaces" do
      let(:chiseids) do
        [
          { character: "A", ids: "⿱⿶⿱𦥑冖同⿱⿳一丿且分 [U]" },
          { character: "B", ids: "⿱ ⿶⿱𦥑 冖同 ⿱⿳ 一丿且分 [U]" }
        ]
      end

      it "ignores a space character" do
        expect(kanjidep["A"][:composition]).to eq("𦥑 冖 同 一 丿 且 分")
      end

      it "ignores multiple space characters" do
        expect(kanjidep["B"][:composition]).to eq("𦥑 冖 同 一 丿 且 分")
      end
    end

    it "adds dependencies to each character" do
      expect(kanjidep["A"][:dependencies]).to eq("dependencies")
    end

    it "adds dependents to each character" do
      expect(kanjidep["A"][:dependents]).to eq("dependents")
    end
  end
end
