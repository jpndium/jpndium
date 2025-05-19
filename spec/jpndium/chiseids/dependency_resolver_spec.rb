# frozen_string_literal: true

RSpec.describe Jpndium::Chiseids::DependencyResolver do
  let(:chiseids) do
    [
      { character: "A", ids: "⿰火水⿱土風" },
      { character: "B", ids: "⿰火A" },
      { character: "C", ids: "" }
    ]
  end
  let(:chiseidsdep) do
    described_class.read(JSON.parse(JSON.dump(chiseids)))
  end

  describe "#read" do
    it "sets the pattern to the prefix characters from the IDS" do
      expect(chiseidsdep[0][:pattern]).to eq("⿰ ⿱")
    end

    context "when the IDS has no prefix characters" do
      let(:chiseids) do
        [{ character: "A", ids: "火水" }]
      end

      it "sets the pattern to an empty array" do
        expect(chiseidsdep[0][:pattern]).to be_nil
      end
    end

    context "when a character has no pattern" do
      it "does not set the pattern" do
        expect(chiseidsdep[2]).not_to have_key(:pattern)
      end
    end

    context "when the IDS has a codepoint between & and ;" do
      let(:chiseids) do
        [{ character: "A", ids: "⿰火&ABC-123A;⿱&DEF-456B;風" }]
      end

      it "reads the codepoint as one character" do
        expect(chiseidsdep[0][:composition])
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
        expect(chiseidsdep[0][:composition]).to eq("鄉 香")
      end

      it "ignores bracketed text" do
        expect(chiseidsdep[1][:composition]).to eq("鄉 香")
      end

      it "ignores multiple bracketed text instances" do
        expect(chiseidsdep[2][:composition]).to eq("鄉 香")
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
        expect(chiseidsdep[0][:composition]).to eq("开 龍")
      end

      it "ignores all additional sequences" do
        expect(chiseidsdep[1][:composition]).to eq("开 龍")
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
        expect(chiseidsdep[0][:composition]).to eq("𦥑 冖 同 一 丿 且 分")
      end

      it "ignores multiple space characters" do
        expect(chiseidsdep[1][:composition]).to eq("𦥑 冖 同 一 丿 且 分")
      end
    end

    context "when a character has no composition" do
      it "does not set the composition" do
        expect(chiseidsdep[2]).not_to have_key(:composition)
      end
    end

    it "adds dependencies to each character" do
      expect(chiseidsdep[0][:dependencies]).to eq("火 水 土 風")
    end

    context "when a character has no dependencies" do
      it "does not set the dependencies" do
        expect(chiseidsdep[2]).not_to have_key(:dependencies)
      end
    end

    it "adds dependents to each character" do
      expect(chiseidsdep[0][:dependents]).to eq("B")
    end

    context "when a character has no dependents" do
      it "does not set the dependents" do
        expect(chiseidsdep[2]).not_to have_key(:dependents)
      end
    end

    context "when given a block" do
      let(:chiseidsdep) do
        [].tap do |actual|
          described_class.read(
            JSON.parse(JSON.dump(chiseids)),
            &actual.method(:append)
          )
        end
      end
      let(:expected) do
        [
          {
            character: "A",
            pattern: "⿰ ⿱",
            composition: "火 水 土 風",
            dependencies: "火 水 土 風",
            dependents: "B"
          },
          {
            character: "B",
            pattern: "⿰",
            composition: "火 A",
            dependencies: "火 水 土 風 A"
          },
          {
            character: "C"
          }
        ]
      end

      it "yields each row to the block" do
        expect(chiseidsdep).to match_array(expected)
      end
    end
  end
end
