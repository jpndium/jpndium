# frozen_string_literal: true

module Jpndium
  # Reads lines from files.
  class FileReader
    def self.read_glob(...)
      new.read_glob(...)
    end

    def self.read(...)
      new.read(...)
    end

    def read_glob(...)
      block_given? ? read_glob_each(...) : read_glob_all(...)
    end

    def read(...)
      block_given? ? read_each(...) : read_all(...)
    end

    protected

    def read_glob_all(*, **)
      [].tap { |l| read_glob_each(*, **, &l.method(:append)) }
    end

    def read_glob_each(glob, &)
      Dir.glob(glob) { |p| read_each(p, &) }
    end

    def read_all(*, **)
      [].tap { |l| read_each(*, **, &l.method(:append)) }
    end

    def read_each(path)
      File.open(path) do |file|
        file.each { |l| yield read_line(l) }
      end
    end

    def read_line(line)
      line
    end
  end
end
