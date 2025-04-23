# frozen_string_literal: true

RSpec.describe JD::Jmnedict::Reader do
  describe ".read" do
    let(:actual) { described_class.read_file("spec/jd/jmnedict/jmnedict.xml") }
    let(:expected) do
      JSON.load_file(
        "spec/jd/jmnedict/jmnedict.json",
        { symbolize_names: true }
      )
    end

    it "returns characters" do
      expected.each_with_index { |e, i| expect(actual[i]).to eq(e) }
    end
  end
end
