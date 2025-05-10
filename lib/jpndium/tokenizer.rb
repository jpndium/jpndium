# frozen_string_literal: true

module JD
  # Tokenizes Japanese text with Sudachi via a python script.
  class Tokenizer
    SCRIPT_NAME = "tokenizer.py"
    SCRIPT_PATH = "#{File.expand_path(__dir__)}/#{SCRIPT_NAME}".freeze

    def initialize(unique: false)
      @unique = unique
    end

    def self.tokenize(input, *, **, &)
      self.open(*, **).tokenize(input).read_close(&)
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
      if input.is_a?(IO)
        write_stream(input)
      elsif input.is_a?(Array)
        input.each(&method(:write))
      else
        write(input)
      end
      self
    end

    def read_close(&)
      read(&).tap { close }
    end

    def read(&)
      close_stdin
      return nil unless @stdout
      return read_each(&) if block_given?

      read_all
    end

    def close
      close_stdin
      terminate_thread.tap { close_stdout }
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

    def write_stream(stream)
      loop { write(stream.readline) }
    rescue EOFError
      # ignore
    end

    def write(text)
      @stdin&.write(text, "\n")
    end

    def read_all
      [].tap { |values| read_each(&values.method(:append)) }
    end

    def read_each
      loop { yield JSON.parse(@stdout.readline.strip) }
    rescue EOFError
      # ignore
    end

    def close_stdin
      @stdin&.close.then { @stdin = nil }
    end

    def close_stdout
      @stdout&.close.then { @stdout = nil }
    end

    def terminate_thread
      @thread&.value.tap { @thread = nil }
    end
  end
end
