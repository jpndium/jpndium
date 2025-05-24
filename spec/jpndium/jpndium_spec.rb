# frozen_string_literal: true

RSpec.describe Jpndium do
  let(:args) { [1, 2] }
  let(:kwargs) { { a: 3, b: 4 } }
  let(:block) { -> {} }

  def expect_forwards(name, target_class, target_method)
    allow(target_class).to receive(target_method)
    described_class.send(name, *args, **kwargs, &block)
    expect(target_class).to have_received_forward(target_method)
  end

  def have_received_forward(*, **)
    have_received(*, **) do |*actual_args, **actual_kwargs, &actual_block|
      expect(actual_args).to match_array(args)
      expect(actual_kwargs).to eq(kwargs)
      expect(actual_block).to eq(block)
    end
  end

  [
    [:read_jsonl, Jpndium::JsonlReader, :read],
    [:write_jsonl, Jpndium::JsonlWriter, :open],
    [:sequence_jsonl, Jpndium::JsonlSequenceWriter, :open],
    [:tokenize, Jpndium::Tokenizer, :tokenize],
    [:tokenize_unique, Jpndium::Tokenizer, :tokenize_unique]
  ].each do |name, target_class, target_method|
    describe ".#{name}" do
      it "forwards to #{target_class.name}.#{target_method}" do
        expect_forwards(name, target_class, target_method)
      end
    end
  end
end
