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
require_relative "jpndium/chiseids/dependency_reader"

require_relative "jpndium/jmdict/reader"
require_relative "jpndium/jmdict/priority_reader"

require_relative "jpndium/jmnedict/reader"
require_relative "jpndium/jmnedict/priority_reader"

require_relative "jpndium/kanjidic/reader"
require_relative "jpndium/kanjidic/dependency_reader"
