# frozen_string_literal: true

require "json"
require "open-uri"
require "zlib"
require_relative "xml_reader"

KANJIDIC_URL = "http://www.edrdg.org/kanjidic/kanjidic2.xml.gz"

TMP_DIR = ENV.fetch("TMP_DIR", "tmp")
directory TMP_DIR

KANJIDIC_XML = File.join(TMP_DIR, "kanjidic.xml")
file KANJIDIC_XML => TMP_DIR do
  Rake::Task["kanjidic:download"].execute
end

DATA_DIR = ENV.fetch("DATA_DIR", "data")
directory DATA_DIR

KANJIDIC_DIR = File.join(DATA_DIR, "kanjidic")
directory KANJIDIC_DIR => DATA_DIR

KANJIDIC_JSONL = File.join(KANJIDIC_DIR, "data.jsonl")

namespace :kanjidic do
  desc "Build kanjidic data file"
  task build: %w[clean update]

  desc "Clean up kanjidic temporary files"
  task :clean do
    rm_rf KANJIDIC_XML
  end

  desc "Update kanjidic data file"
  task update: [KANJIDIC_XML, KANJIDIC_DIR] do
    puts "Updating kanjidic ..."
    File.open(KANJIDIC_JSONL, "w") do |jsonl|
      File.open(KANJIDIC_XML) do |xml|
        JD::Kanjidic::XmlReader.new.read_file(xml) do |character|
          jsonl.write(JSON.dump(character), "\n")
        end
      end
    end
  end

  desc "Download kanjidic"
  task download: TMP_DIR do
    puts "Downloading kanjidic ..."
    URI.parse(KANJIDIC_URL).open do |stream|
      Zlib::GzipReader.open(stream) do |gz|
        IO.copy_stream(gz, KANJIDIC_XML)
      end
    end
  end
end
