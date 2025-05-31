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
  task build: %w[clean download update]

  desc "Clean up kanjidic temporary files"
  task :clean do
    rm_rf kanjidic_xml
  end

  desc "Download kanjidic"
  task download: tmp_dir do
    puts "Downloading kanjidic ..."
    attempts = 3
    begin
      URI.parse(kanjidic_url).open do |stream|
        Zlib::GzipReader.open(stream) do |gz|
          IO.copy_stream(gz, kanjidic_xml)
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

  desc "Update kanjidic data file"
  task update: [kanjidic_dir] do
    puts "Updating kanjidic ..."
    unless File.exist?(kanjidic_xml)
      puts "Error: #{kanjidic_xml} not found."
      puts "Skipping."
      next
    end

    Jpndium.write_jsonl(kanjidic_jsonl) do |kanjidic|
      Jpndium::Kanjidic::Reader.read(kanjidic_xml, &kanjidic.method(:write))
    end
  end

  namespace :dep do
    chiseidsdep_dir = File.join(data_dir, "chiseidsdep")
    chiseidsdep_jsonl = File.join(chiseidsdep_dir, "data.jsonl")
    file chiseidsdep_jsonl => chiseidsdep_dir

    kanjidicdep_dir = File.join(data_dir, "kanjidicdep")
    directory kanjidicdep_dir => data_dir

    kanjidicdep_jsonl = File.join(kanjidicdep_dir, "data.jsonl")

    desc "Build kanjidicdep data file"
    task build: %w[clean kanjidic:build chiseids:dep:build update]

    desc "Clean up kanjidicdep temporary files"
    task :clean

    desc "Update kanjidicdep data file"
    task update: [kanjidic_jsonl, chiseidsdep_jsonl, kanjidicdep_dir] do
      puts "Updating kanjidicdep ..."
      kanjidic = Jpndium.read_jsonl(kanjidic_jsonl)
      chiseidsdep = Jpndium.read_jsonl(chiseidsdep_jsonl)
      Jpndium.write_jsonl(kanjidicdep_jsonl) do |kanjidicdep|
        Jpndium::Kanjidic::DependencyResolver.resolve(kanjidic, chiseidsdep)
          .each(&kanjidicdep.method(:write))
      end
    end
  end
end
