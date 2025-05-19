# frozen_string_literal: true

namespace :jmnedict do
  jmnedict_url = "http://ftp.edrdg.org/pub/Nihongo/JMnedict.xml.gz"

  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  jmnedict_xml = File.join(tmp_dir, "jmnedict.xml")
  file jmnedict_xml

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  jmnedict_dir = File.join(data_dir, "jmnedict")
  directory jmnedict_dir => data_dir

  jmnedict_data_dir = File.join(jmnedict_dir, "data")
  directory jmnedict_data_dir => jmnedict_dir

  desc "Build jmnedict data file"
  task build: %w[clean download update]

  desc "Clean up jmnedict temporary files"
  task :clean do
    rm_rf jmnedict_xml
  end

  desc "Remove jmnedict data"
  task :clean_data do
    rm_rf jmnedict_data_dir
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

  desc "Update jmnedict data file"
  task update: [jmnedict_xml, :clean_data, jmnedict_data_dir] do
    puts "Updating jmnedict ..."
    Jpndium.write_jsonl_sequence(jmnedict_data_dir) do |jmnedict|
      Jpndium::Jmnedict::Reader.read(jmnedict_xml, &jmnedict.method(:write))
    end
  end
end
