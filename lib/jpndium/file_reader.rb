# frozen_string_literal: true

module Jpndium
  # Reads lines from a file.
  class FileReader
    def self.read_file(...)
      new.read_file(...)
    end

    def self.read(...)
      new.read(...)
    end

    def read_file(path, &)
      File.open(path) { |file| read(file, &) }
    end

    def read(stream, &)
      return read_all(stream) unless block_given?

      read_each(stream, &)
    end

    protected

    def read_all(stream)
      [].tap { |values| read_each(stream, &values.method(:append)) }
    end

    def read_each(stream)
      stream.each do |line|
        read_line(line).tap { |value| yield value if value }
      end
    end

    def read_line(line)
      line
    end
  end
end
