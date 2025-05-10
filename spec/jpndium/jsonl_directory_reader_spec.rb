# frozen_string_literal: true

RSpec.describe Jpndium::JsonlDirectoryReader do
  let(:paths) do
    3.times.map { |i| "hello/00#{i + 1}.jsonl" }
  end
  let(:files) do
    paths.length.times.map do |i|
      3.times.map { |j| JSON.dump({ line: "#{i}_#{j}" }) }
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

  describe "#read" do
    it "reads the lines from each file" do
      expected = files.reduce(:+).map(&JSON.method(:load))
      expect(reader.read).to match_array(expected)
    end
  end
end
