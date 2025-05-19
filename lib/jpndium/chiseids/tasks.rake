# frozen_string_literal: true

namespace :chiseids do
  archive_url = "https://github.com/chise/ids/archive/refs/heads/master.zip"

  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  archive_zip = File.join(tmp_dir, "chiseids.zip")
  archive_dir = File.join(tmp_dir, "chiseids")
  archive_files = [
    "IDS-UCS-Basic.txt",
    "IDS-UCS-Ext-A.txt",
    "IDS-UCS-Ext-B-1.txt",
    "IDS-UCS-Ext-B-2.txt",
    "IDS-UCS-Ext-B-3.txt",
    "IDS-UCS-Ext-B-4.txt",
    "IDS-UCS-Ext-B-5.txt",
    "IDS-UCS-Ext-B-6.txt",
    "IDS-UCS-Ext-C.txt",
    "IDS-UCS-Ext-D.txt",
    "IDS-UCS-Ext-E.txt",
    "IDS-UCS-Ext-F.txt",
    "IDS-UCS-Ext-G.txt",
    "IDS-UCS-Ext-H.txt",
    "IDS-UCS-Ext-I.txt"
  ].sort.map { |filename| "#{archive_dir}/ids-master/#{filename}" }
  archive_files.each do |path|
    file path => archive_dir
  end

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  chiseids_dir = File.join(data_dir, "chiseids")
  directory chiseids_dir => data_dir

  chiseids_jsonl = File.join(chiseids_dir, "data.jsonl")

  desc "Build chiseids data file"
  task build: %w[clean download update]

  desc "Clean up chiseids temporary files"
  task :clean do
    rm_rf archive_zip
    rm_rf archive_dir
  end

  desc "Download chiseids"
  task download: tmp_dir do
    puts "Downloading chiseids ..."
    URI.parse(archive_url).open do |stream|
      IO.copy_stream(stream, archive_zip)
    end

    puts "Extracting chiseids ..."
    rm_rf archive_dir
    sh %(unzip #{archive_zip} -d #{archive_dir})
  end

  desc "Update chiseids data file"
  task update: [*archive_files, chiseids_dir] do
    puts "Updating chiseids ..."
    Jpndium.write_jsonl(chiseids_jsonl) do |chiseids|
      archive_files.each do |path|
        Jpndium::Chiseids::Reader.read(path) do |row|
          chiseids.write({ filename: File.basename(path), **row })
        end
      end
    end
  end

  namespace :dep do
    chiseidsdep_dir = File.join(data_dir, "chiseidsdep")
    directory chiseidsdep_dir => data_dir

    chiseidsdep_jsonl = File.join(chiseidsdep_dir, "data.jsonl")

    desc "Build chiseidsdep data file"
    task build: %w[clean chiseids:build update]

    desc "Clean up chiseidsdep temporary files"
    task :clean

    desc "Update chiseidsdep data file"
    task update: [chiseids_jsonl, chiseidsdep_dir] do
      puts "Updating chiseidsdep ..."
      chiseids = Jpndium.read_jsonl(chiseids_jsonl)
      Jpndium.write_jsonl(chiseidsdep_jsonl) do |chiseidsdep|
        write = chiseidsdep.method(:write)
        Jpndium::Chiseids::DependencyReader.read(chiseids, &write)
      end
    end
  end
end
