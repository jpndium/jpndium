# frozen_string_literal: true

RSpec.describe Jpndium::FileSequenceWriter do
  let(:directory_path) { "hello" }
  let(:paths) do
    3.times.map { |i| "#{directory_path}/00#{i + 1}.txt" }
  end
  let(:files) do
    paths.map do
      file = double
      allow(file).to receive(:close)
      allow(file).to receive(:write)
      file
    end
  end
  let(:writer) { described_class.new(directory_path, max_lines: 3) }

  before do
    allow(File).to receive(:open).and_call_original
    paths.length.times do |i|
      allow(File).to receive(:open).with(paths[i], "w").and_return(files[i])
    end
  end

  describe "#open" do
    it "returns self" do
      expect(writer.open).to eq(writer)
    end

    it "does not close the files" do
      writer.open.write("test")
      expect(files[0]).not_to have_received(:close)
    end

    context "when a block is given" do
      it "yields the writer instance" do
        writer.open do |actual|
          expect(actual).to eq(writer)
        end
      end

      it "automatically closes the files" do
        writer.open { |w| w.write("test") }
        expect(files[0]).to have_received(:close)
      end
    end
  end

  describe "#write" do
    it "opens new files" do
      writer.open.write("test").close
      expect(File).to have_received(:open).with(paths[0], "w")
    end

    it "writes values to a file" do
      writer.open.write("test")
      expect(files[0]).to have_received(:write).with("test", "\n")
    end

    it "opens multiple files" do
      (paths.length * 3).times { writer.write("test") }
      paths.each do |path|
        expect(File).to have_received(:open).with(path, "w")
      end
    end

    def test_files_and_lines
      files.each_with_index do |file, i|
        3.times do |j|
          line = "test#{(i + 1) * (j + 1)}"
          yield file, line
        end
      end
    end

    it "writes values to multiple files" do
      test_files_and_lines do |file, line|
        writer.write(line)
        expect(file).to have_received(:write).with(line, "\n")
      end
    end

    it "returns self" do
      expect(writer.open.write("test")).to eq(writer)
    end

    context "when called before open" do
      it "does not raise an error" do
        expect { writer.write("test") }.not_to raise_error
      end
    end
  end

  describe "#close" do
    it "closes the files" do
      writer.open
      9.times { writer.write("test") }
      writer.close
      expect(files).to all(have_received(:close))
    end

    it "returns self" do
      expect(writer.open.write("test").close).to eq(writer)
    end

    context "when called before open" do
      it "does not raise an error" do
        expect { writer.close }.not_to raise_error
      end
    end
  end
end
