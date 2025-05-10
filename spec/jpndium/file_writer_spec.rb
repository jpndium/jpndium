# frozen_string_literal: true

RSpec.describe Jpndium::FileWriter do
  let(:path) { "hello.txt" }
  let(:file) do
    file = double
    allow(file).to receive(:close)
    allow(file).to receive(:write)
    file
  end
  let(:writer) { described_class.new(path) }

  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(path, "w").and_return(file)
  end

  describe ".open" do
    let(:fake_writer) do
      writer = double
      allow(writer).to receive(:open)
      writer
    end
    let(:block) { -> {} }

    before do
      allow(described_class).to receive(:new).and_return(fake_writer)
    end

    def expect_block(actual)
      expect(actual).to eq(block)
    end

    it "passes args to the constructor" do
      described_class.open(path)
      expect(described_class).to have_received(:new).with(path)
    end

    it "calls #open on a new instance" do
      described_class.open(path, &block)
      expect(fake_writer).to have_received(:open).with(no_args) do |&actual|
        expect_block(actual)
      end
    end
  end

  describe "#open" do
    it "opens the file in write mode" do
      writer.open
      expect(File).to have_received(:open).with(path, "w")
    end

    it "does not close the file" do
      writer.open
      expect(file).not_to have_received(:close)
    end

    it "returns self" do
      expect(writer.open).to eq(writer)
    end

    context "when a block is given" do
      it "opens the file in write mode" do
        writer.open do
          expect(File).to have_received(:open).with(path, "w")
        end
      end

      it "yields the writer instance" do
        writer.open do |actual|
          expect(actual).to eq(writer)
        end
      end

      it "automatically closes the file" do
        writer.open { nil }
        expect(file).to have_received(:close)
      end
    end
  end

  describe "#write" do
    let(:value) { "hello" }

    it "writes values to the file" do
      writer.open.write(value)
      expect(file).to have_received(:write).with(value, "\n")
    end

    it "returns self" do
      expect(writer.open.write(value)).to eq(writer)
    end
  end

  describe "#close" do
    it "closes the file" do
      writer.open.close
      expect(file).to have_received(:close)
    end

    it "returns self" do
      expect(writer.open.close).to eq(writer)
    end

    context "when called before open" do
      it "does not raise an error" do
        expect { writer.close }.not_to raise_error
      end
    end
  end
end
