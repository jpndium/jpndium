# frozen_string_literal: true

RSpec.describe Jpndium::DependencyResolver do
  let(:resolver) { described_class.new }

  describe ".resolve" do
    before do
      allow(resolver).to receive(:resolve)
      allow(described_class).to receive(:new).and_return(resolver)
    end

    it "creates a new instance" do
      described_class.resolve
      expect(described_class).to have_received(:new)
    end

    it "calls #resolve on the new instance" do
      described_class.resolve
      expect(resolver).to have_received(:resolve)
    end
  end

  describe "#resolve" do
    def stub_resolve_each(resolutions)
      allow(resolver).to receive_and_yield(:resolve_each, resolutions)
    end

    it "returns all resolutions" do
      stub_resolve_each([1, 2, 3])
      expect(resolver.resolve).to contain_exactly(1, 2, 3)
    end

    context "when passed a block" do
      it "yields each resolution to the block" do
        stub_resolve_each([1, 2, 3])
        actual = [].tap { |a| resolver.resolve(&a.method(:append)) }
        expect(actual).to contain_exactly(1, 2, 3)
      end
    end

    context "when #resolve_each is not implemented" do
      it "raises an error" do
        expect { resolver.resolve }.to raise_error(NoMethodError)
      end
    end
  end
end
