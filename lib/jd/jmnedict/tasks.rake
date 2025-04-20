# frozen_string_literal: true

require "json"
require "open-uri"
require "zlib"
require_relative "reader"

namespace :jmnedict do
  jmnedict_url = "http://ftp.edrdg.org/pub/Nihongo/JMnedict.xml.gz"

  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  jmnedict_xml = File.join(tmp_dir, "jmnedict.xml")

  desc "Clean up jmnedict temporary files"
  task :clean do
    rm_rf jmnedict_xml
  end

  desc "Download jmnedict"
  task download: tmp_dir do
    puts "Downloading jmnedict ..."
    URI.parse(jmnedict_url).open do |stream|
      Zlib::GzipReader.open(stream) do |gz|
        IO.copy_stream(gz, jmnedict_xml)
      end
    end
  end
end
