# frozen_string_literal: true

RSpec.describe Jpndium::DirectoryReader do
  let(:paths) do
    3.times.map { |i| "hello/00#{i + 1}.txt" }
  end
  let(:files) do
    paths.length.times.map do |i|
      3.times.map { |j| "line_#{i}_#{j}" }
    end
  end
  let(:reader) { described_class.new("hello") }

  before do
    allow(Dir).to receive(:glob) do |&block|
      paths.each { |path| block.call(path) }
    end
    allow(File).to receive(:open).and_call_original
    paths.length.times do |i|
      allow(File).to receive(:open).with(paths[i]).and_yield(files[i])
    end
  end

  describe ".read" do
    let(:fake_reader) do
      reader = double
      allow(reader).to receive(:read)
      reader
    end
    let(:block) { -> {} }

    before do
      allow(described_class).to receive(:new).and_return(fake_reader)
    end

    def expect_block(actual)
      expect(actual).to eq(block)
    end

    it "passes args to the constructor" do
      described_class.read("hello")
      expect(described_class).to have_received(:new).with("hello")
    end

    it "calls #read on a new instance" do
      described_class.read("hello", &block)
      expect(fake_reader).to have_received(:read).with(no_args) do |&actual|
        expect_block(actual)
      end
    end
  end

  describe "#read" do
    let(:lines) { files.reduce(:+) }

    it "only reads .txt files by default" do
      reader.read
      expect(Dir).to have_received(:glob).with("hello/*.txt")
    end

    context "when a file extension is provided" do
      let(:reader) { described_class.new("hello", file_extension: "foo") }

      it "only reads files with the provided file extension" do
        reader.read
        expect(Dir).to have_received(:glob).with("hello/*.foo")
      end
    end

    it "returns the lines from each file" do
      expect(reader.read).to match_array(lines)
    end

    context "when a block is given" do
      it "yields the lines from each file" do
        actual = []
        reader.read { |line| actual << line }
        expect(actual).to match_array(lines)
      end
    end
  end
end
