# frozen_string_literal: true

RSpec.describe Jpndium::Tokenizer do
  let(:tokenizer) { described_class.new }
  let(:unique_tokenizer) { described_class.new(unique: true) }

  text = "国家公務員"
  tokens = [
    {
      "text" => "国家",
      "surface" => "国家",
      "part_of_speech" => "名詞,普通名詞,一般,*,*,*",
      "dictionary_form" => "国家",
      "normalized_form" => "国家",
      "reading_form" => "コッカ"
    },
    {
      "text" => "公務",
      "surface" => "公務",
      "part_of_speech" => "名詞,普通名詞,一般,*,*,*",
      "dictionary_form" => "公務",
      "normalized_form" => "公務",
      "reading_form" => "コウム"
    },
    {
      "text" => "員",
      "surface" => "員",
      "part_of_speech" => "接尾辞,名詞的,一般,*,*,*",
      "dictionary_form" => "員",
      "normalized_form" => "員",
      "reading_form" => "イン"
    },
    {
      "text" => "公務員",
      "composition" => "公務 員"
    },
    {
      "text" => "国家公務員",
      "composition" => "国家 公務員"
    }
  ]

  def stub_popen2
    [mock_stdin, mock_stdout, mock_thread].tap do |mocks|
      allow(Open3).to receive(:popen2).and_return(mocks)
    end
  end

  def mock_stdin
    double.tap do |stdin|
      allow(stdin).to receive(:write)
      allow(stdin).to receive(:close)
    end
  end

  def mock_stdout
    double.tap do |stdout|
      allow(stdout).to receive(:close)
    end
  end

  def mock_thread
    double.tap do |thread|
      allow(thread).to receive(:value).and_return("thread_status")
    end
  end

  def mock_stream(lines)
    double.tap do |stream|
      allow(stream).to receive(:is_a?).and_return(true)
      allow(stream).to receive(:readline).and_invoke(
        *lines.map { |line| -> { "#{line}\n" } },
        -> { raise EOFError }
      )
    end
  end

  describe "#open" do
    it "returns the tokenizer" do
      expect(tokenizer.open).to eq(tokenizer)
      tokenizer.close
    end

    context "when a block is passed" do
      it "yields the tokenizer" do
        expect { |b| tokenizer.open(&b) }.to yield_with_args(tokenizer)
      end

      it "closes the tokenizer after the block" do
        allow(tokenizer).to receive(:close)
        tokenizer.open { nil }
        expect(tokenizer).to have_received(:close)
      end
    end
  end

  describe "#tokenize" do
    it "returns the tokenizer" do
      expect(tokenizer.open.tokenize(text)).to eq(tokenizer)
      tokenizer.close
    end

    context "when passed a string" do
      it "tokenizes the string" do
        expect(tokenizer.open.tokenize(text).read).to eq(tokens)
      end
    end

    context "when passed an array of strings" do
      it "tokenizes the array of strings" do
        actual = tokenizer.open.tokenize([text, text]).read
        expect(actual).to eq([*tokens, *tokens])
      end
    end

    context "when passed an array of strings in unique mode" do
      it "uniquely tokenizes the array of strings" do
        actual = unique_tokenizer.open.tokenize([text, text]).read
        expect(actual).to eq(tokens)
      end
    end

    context "when passed a stream" do
      it "tokenizes each line of the stream" do
        stream = mock_stream([text, text])
        actual = tokenizer.open.tokenize(stream).read
        expect(actual).to eq([*tokens, *tokens])
      end
    end

    context "when passed a stream in unique mode" do
      it "uniquely tokenizes each line of the stream" do
        stream = mock_stream([text, text])
        actual = unique_tokenizer.open.tokenize(stream).read
        expect(actual).to eq(tokens)
      end
    end

    context "when the tokenizer is not open" do
      it "does nothing" do
        expect { tokenizer.tokenize(text) }.not_to raise_error
      end
    end
  end

  describe "#read" do
    it "return tokens" do
      expect(tokenizer.open.tokenize(text).read).to eq(tokens)
    end

    context "when the tokenizer is not open" do
      it "returns nil" do
        expect(tokenizer.read).to be_nil
      end
    end

    context "when a block is passed" do
      it "yields each token" do
        actual = []
        tokenizer.open.tokenize(text).read(&actual.method(:append))
        expect(actual).to eq(tokens)
      end
    end
  end

  describe "#close" do
    it "closes the process's stdin" do
      stdin, = stub_popen2
      tokenizer.open.close
      expect(stdin).to have_received(:close)
    end

    it "closes the process's stdout" do
      _, stdout, = stub_popen2
      tokenizer.open.close
      expect(stdout).to have_received(:close)
    end

    it "returns the process's thread status" do
      stub_popen2
      expect(tokenizer.open.close).to eq("thread_status")
    end

    context "when the tokenizer is not open" do
      it "does nothing" do
        expect { tokenizer.close }.not_to raise_error
      end
    end
  end

  describe ".open" do
    it "returns the tokenizer" do
      tokenizer = described_class.open
      expect(tokenizer).to be_a(described_class)
      tokenizer.close
    end

    context "when a block is passed" do
      it "yields the tokenizer" do
        tokenizer = nil
        described_class.open { |t| tokenizer = t }
        expect(tokenizer).to be_a(described_class)
      end

      it "closes the tokenizer after the block" do
        tokenizer = described_class.open { |t| allow(t).to receive(:close) }
        expect(tokenizer).to have_received(:close)
      end
    end
  end

  describe ".tokenize" do
    context "when passed a string" do
      it "tokenizes the string" do
        expect(described_class.tokenize(text)).to eq(tokens)
      end
    end

    context "when passed an array of strings" do
      it "tokenizes the array of strings" do
        actual = described_class.tokenize([text, text])
        expect(actual).to eq([*tokens, *tokens])
      end
    end

    context "when passed an array of strings in unique mode" do
      it "uniquely tokenizes the array of strings" do
        actual = described_class.tokenize([text, text], unique: true)
        expect(actual).to eq(tokens)
      end
    end

    context "when passed a stream" do
      it "tokenizes each line of the stream" do
        stream = mock_stream([text, text])
        actual = described_class.tokenize(stream)
        expect(actual).to eq([*tokens, *tokens])
      end
    end

    context "when passed a stream in unique mode" do
      it "uniquely tokenizes each line of the stream" do
        stream = mock_stream([text, text])
        actual = described_class.tokenize(stream, unique: true)
        expect(actual).to eq(tokens)
      end
    end

    context "when a block is passed" do
      it "yields each token to the block" do
        actual = []
        described_class.tokenize(text, &actual.method(:append))
        expect(actual).to eq(tokens)
      end
    end
  end
end
