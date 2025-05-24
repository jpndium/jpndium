# frozen_string_literal: true

require "json"
require "open3"
require "nokogiri"

require_relative "jpndium/file_reader"
require_relative "jpndium/file_writer"
require_relative "jpndium/file_sequence_writer"

require_relative "jpndium/jsonl_reader"
require_relative "jpndium/jsonl_writer"
require_relative "jpndium/jsonl_sequence_writer"

require_relative "jpndium/xml_helpers"
require_relative "jpndium/xml_reader"

require_relative "jpndium/tokenizer"
require_relative "jpndium/dependency_resolver"

require_relative "jpndium/chiseids/reader"
require_relative "jpndium/chiseids/dependency_resolver"

require_relative "jpndium/jmdict/reader"
require_relative "jpndium/jmdict/priority_reader"

require_relative "jpndium/jmnedict/reader"
require_relative "jpndium/jmnedict/priority_reader"

require_relative "jpndium/kanjidic/reader"
require_relative "jpndium/kanjidic/dependency_resolver"

# A compendium of data related to the Japanese language.
module Jpndium
  class << self
    def read_jsonl(...)
      Jpndium::JsonlReader.read(...)
    end

    def write_jsonl(...)
      Jpndium::JsonlWriter.open(...)
    end

    def write_jsonl_sequence(...)
      Jpndium::JsonlSequenceWriter.open(...)
    end

    def tokenize_unique(...)
      Jpndium::Tokenizer.tokenize_unique(...)
    end

    def tokenize(...)
      Jpndium::Tokenizer.tokenize(...)
    end
  end
end
