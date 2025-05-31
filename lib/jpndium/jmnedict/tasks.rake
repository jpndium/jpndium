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

  desc "Download jmnedict"
  task download: tmp_dir do
    puts "Downloading jmnedict ..."
    attempts = 3
    begin
      URI.parse(jmnedict_url).open do |stream|
        Zlib::GzipReader.open(stream) do |gz|
          IO.copy_stream(gz, jmnedict_xml)
        end
      end
    rescue StandardError => e
      puts "Error: #{e}"
      attempts -= 1
      if attempts.positive?
        puts "Retrying ..."
        sleep(10)
        retry
      end
      puts "Skipping."
    end
  end

  desc "Update jmnedict data file"
  task update: [jmnedict_data_dir] do
    puts "Updating jmnedict ..."
    unless File.exist?(jmnedict_xml)
      puts "Error: #{jmnedict_xml} not found."
      puts "Skipping."
      next
    end

    rm_rf Dir["#{jmnedict_data_dir}/*"]
    Jpndium.sequence_jsonl(jmnedict_data_dir) do |jmnedict|
      Jpndium::Jmnedict::Reader.read(jmnedict_xml, &jmnedict.method(:write))
    end
  end

  namespace :dep do
    kanjidic_jsonl = File.join(data_dir, "kanjidic/data.jsonl")
    file kanjidic_jsonl

    jmnedictdep_dir = File.join(data_dir, "jmnedictdep")
    directory jmnedictdep_dir => data_dir

    jmnedictdep_data_dir = File.join(jmnedictdep_dir, "data")
    directory jmnedictdep_data_dir => jmnedictdep_dir

    jmnedict_data_glob = "#{jmnedict_data_dir}/*.jsonl"

    desc "Build jmnedictdep data file"
    task build: %w[clean jmnedict:build kanjidic:build update]

    desc "Clean up jmnedictdep temporary files"
    task :clean

    desc "Update jmnedictdep data file"
    task update: [jmnedict_data_dir, kanjidic_jsonl, jmnedictdep_data_dir] do
      puts "Updating jmnedictdep ..."
      jmnedict = Jpndium::JsonlReader.read_glob(jmnedict_data_glob)
      kanjidic = Jpndium::JsonlReader.read(kanjidic_jsonl)
      rm_rf Dir["#{jmnedictdep_data_dir}/*"]
      Jpndium::JsonlWriter.sequence(jmnedictdep_data_dir) do |jmnedictdep|
        Jpndium::Jmnedict::DependencyResolver
          .resolve(jmnedict, kanjidic, &jmnedictdep.method(:write))
      end
    end
  end
end
