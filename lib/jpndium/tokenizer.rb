# frozen_string_literal: true

module Jpndium
  # Tokenizes Japanese text with Sudachi via a python script.
  class Tokenizer
    SCRIPT_NAME = "tokenizer.py"
    SCRIPT_PATH = "#{File.expand_path(__dir__)}/#{SCRIPT_NAME}".freeze

    def initialize(unique: false)
      @unique = unique
    end

    def self.tokenize(...)
      return tokenize_all(...) unless block_given?

      tokenize_each(...)
    end

    def self.tokenize_all(input, *, **)
      [].tap { |tokens| tokenize_each(input, *, **, &tokens.method(:append)) }
    end

    def self.tokenize_each(input, *, **, &)
      self.open(*, **) { |tokenizer| tokenizer.read(&).tokenize(input) }
    end

    def self.open(*, **, &)
      new(*, **).open(&)
    end

    def open
      @stdin, @stdout, @thread = Open3.popen2(command)
      (yield self).tap { close } if block_given?
      self
    end

    def tokenize(input)
      write(input).then { self }
    end

    def read
      @reader = Thread.new do
        readlines(@stdout) { |line| yield JSON.parse(line) }
      end
      self
    end

    def close
      close_stdin
      terminate_reader
      close_stdout
      terminate_thread
    end

    protected

    def command
      "python #{SCRIPT_PATH} #{args}"
    end

    def args
      args = []
      args << "--unique" if @unique
      args.join(" ")
    end

    def write(input)
      if input.is_a?(IO)
        write_stream(input)
      elsif input.is_a?(Array)
        write_array(input)
      else
        write_string(input)
      end
    end

    def write_stream(input)
      readlines(input, &method(:write_string))
    end

    def write_array(input)
      input.each(&method(:write_string))
    end

    def write_string(input)
      @stdin&.write(input, "\n")
    end

    def readlines(stream)
      loop { yield stream.readline } if stream
    rescue EOFError
      # ignore
    end

    def close_stdin
      @stdin&.close.then { @stdin = nil }
    end

    def terminate_reader
      @reader&.value.tap { @reader = nil }
    end

    def close_stdout
      @stdout&.close.then { @stdout = nil }
    end

    def terminate_thread
      @thread&.value.tap { @thread = nil }
    end
  end
end
