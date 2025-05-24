# frozen_string_literal: true

RSpec.describe Jpndium::FileWriter do
  path = "path"

  let(:writer) { described_class.new(path) }
  let(:files) do
    2.times.map do
      double.tap do |file|
        allow(file).to receive(:write)
        allow(file).to receive(:close)
      end
    end
  end

  def have_received_block(name, expected)
    have_received(name) do |&actual|
      expect(actual).to eq(expected)
    end
  end

  describe ".sequence" do
    before do
      allow(described_class).to receive(:new).and_return(writer)
      allow(writer).to receive(:sequence).and_call_original
    end

    it "creates a new instance" do
      described_class.sequence(path)
      expect(described_class).to have_received(:new).with(path)
    end

    it "returns the new instance" do
      expect(described_class.sequence(path)).to eq(writer)
    end

    it "calls #sequence on the new instance" do
      described_class.sequence(path, max_lines: 3)
      expect(writer).to have_received(:sequence).with(max_lines: 3)
    end

    context "when given a block" do
      it "yields the writer to the block" do
        actual = nil
        described_class.sequence(path) { |a| actual = a }
        expect(actual).to eq(writer)
      end

      it "passes the block to #sequence" do
        block = ->(*) {}
        described_class.sequence(path, &block)
        expect(writer).to have_received_block(:sequence, block)
      end
    end
  end

  describe ".open" do
    before do
      allow(described_class).to receive(:new).and_return(writer)
      allow(writer).to receive(:open).and_call_original
    end

    it "creates a new instance" do
      described_class.open(path)
      expect(described_class).to have_received(:new).with(path)
    end

    it "returns the new instance" do
      expect(described_class.open(path)).to eq(writer)
    end

    it "calls #open on the new instance" do
      described_class.open(path)
      expect(writer).to have_received(:open)
    end

    context "when given a block" do
      it "yields the writer to the block" do
        actual = nil
        described_class.open(path) { |a| actual = a }
        expect(actual).to eq(writer)
      end

      it "passes the block to #open" do
        block = ->(*) {}
        described_class.open(path, &block)
        expect(writer).to have_received_block(:open, block)
      end
    end
  end

  describe "#sequence" do
    it "returns the writer" do
      expect(writer.sequence).to eq(writer)
    end

    context "when max_lines is given" do
      before do
        allow(File).to receive(:open).and_call_original
        [
          ["001.txt", files[0]],
          ["002.txt", files[1]]
        ].each do |filename, file|
          allow(File).to receive(:open)
            .with("#{path}/#{filename}", "w")
            .and_return(file)
        end

        writer.sequence(max_lines: 3) do
          4.times { writer.write("test") }
        end
      end

      it "opens new sequence files", :aggregate_failures do
        expect(File).to have_received(:open)
          .with("#{path}/001.txt", "w")
          .with("#{path}/002.txt", "w")
      end

      it "writes no more lines than the limit", :aggregate_failures do
        expect(files[0]).to have_received(:write).exactly(3).times
        expect(files[1]).to have_received(:write).exactly(1).times
      end
    end

    context "when max_digits is given" do
      before do
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open)
          .with("#{path}/0001.txt", "w")
          .and_return(files[0])
      end

      it "zero pads the given number of digits" do
        writer.sequence(max_digits: 4) do
          writer.write("test")
        end
        expect(File).to have_received(:open).with("#{path}/0001.txt", "w")
      end
    end

    context "when file_extension is given" do
      before do
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open)
          .with("#{path}/001.foobar", "w")
          .and_return(files[0])
      end

      it "writes to files with the given extension" do
        writer.sequence(file_extension: "foobar") do
          writer.write("test")
        end
        expect(File).to have_received(:open).with("#{path}/001.foobar", "w")
      end
    end

    context "when a block is given" do
      it "yields the writer to the block" do
        actual = nil
        writer.sequence { |w| actual = w }
        expect(actual).to eq(writer)
      end
    end
  end

  describe "#open" do
    it "returns the writer" do
      expect(writer.open).to eq(writer)
    end

    context "when a block is given" do
      it "yields the writer to the block" do
        actual = nil
        writer.open { |w| actual = w }
        expect(actual).to eq(writer)
      end

      it "closes the writer after yielding to the block" do
        allow(writer).to receive(:close)
        writer.open { nil }
        expect(writer).to have_received(:close)
      end
    end
  end

  describe "#write" do
    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path, "w").and_return(files[0])
    end

    it "writes the line to the file" do
      writer.open.write("test")
      expect(files[0]).to have_received(:write).with("test", "\n")
    end

    context "when the file is not open" do
      it "opens the file" do
        writer.write("test")
        expect(File).to have_received(:open).with(path, "w")
      end

      it "writes to the file" do
        writer.write("test")
        expect(files[0]).to have_received(:write).with("test", "\n")
      end
    end

    context "when max_lines is exceeded for the current file" do
      before do
        allow(File).to receive(:open).and_call_original
        [
          ["001.txt", files[0]],
          ["002.txt", files[1]]
        ].each do |filename, file|
          allow(File).to receive(:open)
            .with("#{path}/#{filename}", "w")
            .and_return(file)
        end

        writer.sequence(max_lines: 3) do
          4.times { writer.write("test") }
        end
      end

      it "opens new sequence files", :aggregate_failures do
        expect(File).to have_received(:open)
          .with("#{path}/001.txt", "w")
          .with("#{path}/002.txt", "w")
      end

      it "writes no more lines than the limit", :aggregate_failures do
        expect(files[0]).to have_received(:write).exactly(3).times
        expect(files[1]).to have_received(:write).exactly(1).times
      end
    end
  end

  describe "#close" do
    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path, "w").and_return(files[0])
    end

    it "returns the writer" do
      expect(writer.close).to eq(writer)
    end

    it "closes the file" do
      writer.open.write("test").close
      expect(files[0]).to have_received(:close)
    end

    context "when no files are open" do
      it "does nothing" do
        expect { writer.close }.not_to raise_error
      end
    end

    context "when called additional times" do
      it "does nothing" do
        expect { writer.close.close }.not_to raise_error
      end
    end

    context "when multiple sequence files are open" do
      before do
        allow(File).to receive(:open).and_call_original
        [
          ["001.txt", files[0]],
          ["002.txt", files[1]]
        ].each do |filename, file|
          allow(File).to receive(:open)
            .with("#{path}/#{filename}", "w")
            .and_return(file)
        end

        writer.sequence(max_lines: 3) do
          4.times { writer.write("test") }
        end
      end

      it "closes each sequence file" do
        writer.close
        expect(files).to all(have_received(:close))
      end
    end
  end
end
