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
  task build: %w[clean download update]

  desc "Clean up jmdict temporary files"
  task :clean do
    puts "[jmdict] Cleaning ..."
    rm_rf jmdict_xml
  end

  desc "Download jmdict"
  task download: tmp_dir do
    puts "[jmdict] Downloading ..."
    attempts = 3
    begin
      URI.parse(jmdict_url).open do |stream|
        Zlib::GzipReader.open(stream) do |gz|
          IO.copy_stream(gz, jmdict_xml)
        end
      end
    rescue StandardError => e
      puts "[jmdict] Error: #{e}"
      attempts -= 1
      if attempts.positive?
        puts "[jmdict] Retrying ..."
        sleep(10)
        retry
      end
      puts "[jmdict] Skipping."
    end
  end

  desc "Update jmdict data file"
  task update: [jmdict_data_dir] do
    puts "[jmdict] Updating ..."
    unless File.exist?(jmdict_xml)
      puts "[jmdict] Error: #{jmdict_xml} not found."
      puts "[jmdict] Skipping."
      next
    end

    rm_rf Dir["#{jmdict_data_dir}/*"]
    Jpndium.sequence_jsonl(jmdict_data_dir) do |jmdict|
      Jpndium::Jmdict::Reader.read(jmdict_xml, &jmdict.method(:write))
    end
  end

  namespace :dep do
    kanjidic_jsonl = File.join(data_dir, "kanjidic/data.jsonl")
    file kanjidic_jsonl

    jmdictdep_dir = File.join(data_dir, "jmdictdep")
    directory jmdictdep_dir => data_dir

    jmdictdep_data_dir = File.join(jmdictdep_dir, "data")
    directory jmdictdep_data_dir => jmdictdep_dir

    jmdict_data_glob = "#{jmdict_data_dir}/*.jsonl"

    desc "Build jmdictdep data file"
    task build: %w[clean jmdict:build kanjidic:build update]

    desc "Clean up jmdictdep temporary files"
    task :clean do
      puts "[jmdictdep] Cleaning ..."
    end

    desc "Update jmdictdep data file"
    task update: [jmdict_data_dir, kanjidic_jsonl, jmdictdep_data_dir] do
      puts "[jmdictdep] Updating ..."
      jmdict = Jpndium::JsonlReader.read_glob(jmdict_data_glob)
      kanjidic = Jpndium::JsonlReader.read(kanjidic_jsonl)
      rm_rf Dir["#{jmdictdep_data_dir}/*"]
      Jpndium::JsonlWriter.sequence(jmdictdep_data_dir) do |jmdictdep|
        Jpndium::Jmdict::DependencyResolver
          .resolve(jmdict, kanjidic, &jmdictdep.method(:write))
      end
    end
  end
end
