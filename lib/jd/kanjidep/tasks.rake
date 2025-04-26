# frozen_string_literal: true

namespace :kanjidep do
  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  chiseids_dir = File.join(data_dir, "chiseids")
  chiseids_jsonl = File.join(chiseids_dir, "data.jsonl")
  file chiseids_jsonl

  kanjidep_dir = File.join(data_dir, "kanjidep")
  directory kanjidep_dir => data_dir

  kanjidep_jsonl = File.join(kanjidep_dir, "data.jsonl")

  desc "Build kanjidep data file"
  task build: %w[clean update]

  desc "Clean up kanjidic temporary files"
  task :clean

  desc "Update kanjidep data file"
  task update: ["chiseids:update", chiseids_jsonl, kanjidep_dir] do
    puts "Updating kanjidep ..."
    chiseids = JD::JsonlReader.read_file(chiseids_jsonl)
    JD::JsonlWriter.open(kanjidep_jsonl) do |kanjidep|
      JD::Kanji::DependencyReader.read(chiseids).each(&kanjidep.method(:write))
    end
  end
end
