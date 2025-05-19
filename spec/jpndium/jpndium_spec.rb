# frozen_string_literal: true

RSpec.describe Jpndium do
  let(:args) { [1, 2] }
  let(:kwargs) { { a: 3, b: 4 } }
  let(:block) { -> {} }

  def have_received_forward(*, **)
    have_received(*, **) do |*actual_args, **actual_kwargs, &actual_block|
      expect(actual_args).to match_array(args)
      expect(actual_kwargs).to eq(kwargs)
      expect(actual_block).to eq(block)
    end
  end

  describe ".read_jsonl" do
    it "forwards to #{Jpndium::JsonlReader.name}" do
      allow(Jpndium::JsonlReader).to receive(:read)
      described_class.read_jsonl(*args, **kwargs, &block)
      expect(Jpndium::JsonlReader).to have_received_forward(:read)
    end
  end

  describe ".write_jsonl" do
    it "forwards to #{Jpndium::JsonlWriter.name}" do
      allow(Jpndium::JsonlWriter).to receive(:open)
      described_class.write_jsonl(*args, **kwargs, &block)
      expect(Jpndium::JsonlWriter).to have_received_forward(:open)
    end
  end

  describe ".write_jsonl_sequence" do
    it "forwards to #{Jpndium::JsonlSequenceWriter.name}" do
      allow(Jpndium::JsonlSequenceWriter).to receive(:open)
      described_class.write_jsonl_sequence(*args, **kwargs, &block)
      expect(Jpndium::JsonlSequenceWriter).to have_received_forward(:open)
    end
  end

  describe ".tokenize" do
    it "forwards to #{Jpndium::Tokenizer.name}" do
      allow(Jpndium::Tokenizer).to receive(:tokenize)
      described_class.tokenize(*args, **kwargs, &block)
      expect(Jpndium::Tokenizer).to have_received_forward(:tokenize)
    end
  end

  describe ".tokenize_unique" do
    it "forwards to #{Jpndium::Tokenizer.name}" do
      kwargs[:unique] = true
      allow(Jpndium::Tokenizer).to receive(:tokenize)
      described_class.tokenize_unique(*args, **kwargs, &block)
      expect(Jpndium::Tokenizer).to have_received_forward(:tokenize)
    end
  end
end
