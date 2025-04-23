# frozen_string_literal: true

namespace :kanjidic do
  kanjidic_url = "http://www.edrdg.org/kanjidic/kanjidic2.xml.gz"

  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  kanjidic_xml = File.join(tmp_dir, "kanjidic.xml")
  file kanjidic_xml

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  kanjidic_dir = File.join(data_dir, "kanjidic")
  directory kanjidic_dir => data_dir

  kanjidic_jsonl = File.join(kanjidic_dir, "data.jsonl")

  desc "Build kanjidic data file"
  task build: %w[clean update]

  desc "Clean up kanjidic temporary files"
  task :clean do
    rm_rf kanjidic_xml
  end

  desc "Update kanjidic data file"
  task update: ["download", kanjidic_xml, kanjidic_dir] do
    puts "Updating kanjidic ..."
    File.open(kanjidic_jsonl, "w") do |kanjidic|
      JD::Kanjidic::Reader.read_file(kanjidic_xml) do |row|
        kanjidic.write(JSON.dump(row), "\n")
      end
    end
  end

  desc "Download kanjidic"
  task download: tmp_dir do
    puts "Downloading kanjidic ..."
    URI.parse(kanjidic_url).open do |stream|
      Zlib::GzipReader.open(stream) do |gz|
        IO.copy_stream(gz, kanjidic_xml)
      end
    end
  end
end
