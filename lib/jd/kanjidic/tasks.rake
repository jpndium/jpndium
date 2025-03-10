# frozen_string_literal: true

require "open-uri"
require "zlib"

KANJIDIC_URL = "http://www.edrdg.org/kanjidic/kanjidic2.xml.gz"

TMP_DIR = ENV.fetch("TMP_DIR", "tmp")
directory TMP_DIR

KANJIDIC_XML = File.join(TMP_DIR, "kanjidic.xml")
file KANJIDIC_XML do
  Rake::Task["kanjidic:download"]
end

namespace :kanjidic do
  task build: %w[clean download]

  desc "Clean up kanjidic files"
  task :clean do
    rm_rf KANJIDIC_XML
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
