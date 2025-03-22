# frozen_string_literal: true

module JD
  # Reads lines from a file.
  class FileReader
    def read_file(path, &)
      File.open(path) { |file| read(file, &) }
    end

    def read(stream, &)
      if block_given?
        read_each(stream, &)
      else
        read_all(stream)
      end
    end

    def read_all(stream)
      values = []
      read_each(stream) { |value| values << value }

      values
    end

    def read_each(stream)
      stream.each do |line|
        value = read_line(line)
        next unless value

        yield value
      end
    end

    def read_line(_line)
      raise NoMethodError, "#{self.class} must implement #{__method__}"
    end
  end
end
