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
    JD::JsonlWriter.open(kanjidic_jsonl) do |kanjidic|
      JD::Kanjidic::Reader.read_file(kanjidic_xml, &kanjidic.method(:write))
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

  namespace :dep do
    chiseidsdep_dir = File.join(data_dir, "chiseidsdep")
    chiseidsdep_jsonl = File.join(chiseidsdep_dir, "data.jsonl")
    file chiseidsdep_jsonl => chiseidsdep_dir

    kanjidicdep_dir = File.join(data_dir, "kanjidicdep")
    directory kanjidicdep_dir => data_dir

    kanjidicdep_jsonl = File.join(kanjidicdep_dir, "data.jsonl")

    desc "Build kanjidicdep data file"
    task build: %w[clean update]

    desc "Clean up kanjidicdep temporary files"
    task :clean

    update_dependencies = [
      "kanjidic:update",
      kanjidic_jsonl,
      "chiseids:dep:update",
      chiseidsdep_jsonl,
      kanjidicdep_dir
    ]

    desc "Update kanjidicdep data file"
    task update: update_dependencies do
      puts "Updating kanjidicdep ..."
      kanjidic = JD::JsonlReader.read_file(kanjidic_jsonl)
      chiseidsdep = JD::JsonlReader.read_file(chiseidsdep_jsonl)
      JD::JsonlWriter.open(kanjidicdep_jsonl) do |kanjidicdep|
        write = kanjidicdep.method(:write)
        JD::Kanjidic::DependencyReader.read(kanjidic, chiseidsdep).each(&write)
      end
    end
  end
end
