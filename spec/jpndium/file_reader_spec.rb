# frozen_string_literal: true

RSpec.describe Jpndium::FileReader do
  path = "foo/bar.txt"
  file = %w[one two three]

  glob = "foo/*.txt"
  paths = ["foo/001.txt", "foo/002.txt", "foo/003.txt"]
  files = [
    %w[one1 two1 three1],
    %w[one2 two2 three2],
    %w[one3 two3 three3]
  ]

  let(:reader) { described_class.new }
  let(:instance) do
    double.tap do |instance|
      allow(instance).to receive(:read_glob)
      allow(instance).to receive(:read)
    end
  end

  def stub_dir_glob(paths)
    allow(Dir).to receive(:glob) do |_, &block|
      paths.each { |p| block.call(p) }
    end
  end

  def stub_file_open(paths, files)
    allow(File).to receive(:open).and_call_original
    paths.zip(files).each do |path, file|
      allow(File).to receive(:open).with(path).and_yield(file)
    end
  end

  describe ".read_glob" do
    before do
      allow(described_class).to receive(:new).and_return(instance)
      described_class.read_glob(glob)
    end

    it "instantiates a file reader" do
      expect(described_class).to have_received(:new)
    end

    it "calls #read_glob" do
      expect(instance).to have_received(:read_glob).with(glob)
    end
  end

  describe ".read" do
    before do
      allow(described_class).to receive(:new).and_return(instance)
      described_class.read(path)
    end

    it "instantiates a file reader" do
      expect(described_class).to have_received(:new)
    end

    it "calls #read" do
      expect(instance).to have_received(:read).with(path)
    end
  end

  describe "#read_glob" do
    before do
      stub_dir_glob(paths)
      stub_file_open(paths, files)
    end

    it "returns all lines from the files" do
      expect(reader.read_glob(glob)).to eq(files.reduce(:+))
    end

    context "when given a block" do
      it "yields each line from the files to the block" do
        actual = [].tap { |a| reader.read_glob(glob, &a.method(:append)) }
        expect(actual).to eq(files.reduce(:+))
      end
    end
  end

  describe "#read" do
    before { stub_file_open([path], [file]) }

    it "returns all lines from the file" do
      expect(reader.read(path)).to eq(file)
    end

    context "when given a block" do
      it "yields each line from the file to the block" do
        actual = [].tap { |a| reader.read(path, &a.method(:append)) }
        expect(actual).to eq(file)
      end
    end
  end
end
