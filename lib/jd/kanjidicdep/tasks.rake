# frozen_string_literal: true

namespace :kanjidicdep do
  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  kanjidic_dir = File.join(data_dir, "kanjidic")
  kanjidic_jsonl = File.join(kanjidic_dir, "data.jsonl")
  file kanjidic_jsonl => kanjidic_dir

  kanjidep_dir = File.join(data_dir, "kanjidep")
  kanjidep_jsonl = File.join(kanjidep_dir, "data.jsonl")
  file kanjidep_jsonl => kanjidep_dir

  kanjidicdep_dir = File.join(data_dir, "kanjidicdep")
  directory kanjidicdep_dir => data_dir

  kanjidicdep_jsonl = File.join(kanjidicdep_dir, "data.jsonl")

  desc "Build kanjidicdep data file"
  task build: %w[kanjidep:update kanjidic:update clean update]

  desc "Clean up kanjidicdep temporary files"
  task :clean

  update_dependencies = [
    "kanjidic:update",
    kanjidic_jsonl,
    "kanjidep:update",
    kanjidep_jsonl,
    kanjidicdep_dir
  ]

  desc "Update kanjidicdep data file"
  task update: update_dependencies do
    puts "Updating kanjidicdep ..."
    kanjidic = JD::JsonlReader.read_file(kanjidic_jsonl)
    kanjidep = JD::JsonlReader.read_file(kanjidep_jsonl)
    JD::JsonlWriter.open(kanjidicdep_jsonl) do |kanjidicdep|
      write = kanjidicdep.method(:write)
      JD::Kanjidic::DependencyReader.read(kanjidic, kanjidep).each(&write)
    end
  end
end
