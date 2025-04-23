# frozen_string_literal: true

RSpec.describe JD::Jmdict::Reader do
  describe ".read" do
    let(:actual) { described_class.read_file("spec/jd/jmdict/jmdict.xml") }
    let(:expected) do
      JSON.load_file(
        "spec/jd/jmdict/jmdict.json",
        { symbolize_names: true }
      )
    end

    it "returns entries" do
      expected.each_with_index { |e, i| expect(actual[i]).to eq(e) }
    end
  end
end
