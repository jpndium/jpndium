# frozen_string_literal: true

namespace :jmdict do
  jmdict_url = "http://ftp.edrdg.org/pub/Nihongo/JMdict_e.gz"

  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  jmdict_xml = File.join(tmp_dir, "jmdict.xml")
  file jmdict_xml

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  jmdict_dir = File.join(data_dir, "jmdict")
  directory jmdict_dir => data_dir

  jmdict_data_dir = File.join(jmdict_dir, "data")
  directory jmdict_data_dir => jmdict_dir

  desc "Build jmdict data file"
  task build: %w[clean update]

  desc "Clean up jmdict temporary files"
  task :clean do
    rm_rf jmdict_xml
  end

  desc "Remove jmdict data"
  task :clean_data do
    rm_rf jmdict_data_dir
  end

  desc "Download jmdict"
  task download: tmp_dir do
    puts "Downloading jmdict ..."
    URI.parse(jmdict_url).open do |stream|
      Zlib::GzipReader.open(stream) do |gz|
        IO.copy_stream(gz, jmdict_xml)
      end
    end
  end

  desc "Update jmdict data file"
  task update: [:download, jmdict_xml, :clean_data, jmdict_data_dir] do
    puts "Updating jmdict ..."
    Jpndium::JsonlSequenceWriter.open(jmdict_data_dir) do |jmdict|
      Jpndium::Jmdict::Reader.read(jmdict_xml, &jmdict.method(:write))
    end
  end
end
