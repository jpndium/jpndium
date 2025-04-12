# frozen_string_literal: true

require_relative "../jsonl_reader"
require_relative "reader"

namespace :kanjidicdep do
  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  kanjidep_dir = File.join(data_dir, "kanjidep")
  kanjidep_jsonl = File.join(kanjidep_dir, "data.jsonl")
  file kanjidep_jsonl => kanjidep_dir

  kanjidic_dir = File.join(data_dir, "kanjidic")
  kanjidic_jsonl = File.join(kanjidic_dir, "data.jsonl")
  file kanjidic_jsonl => kanjidic_dir

  kanjidicdep_dir = File.join(data_dir, "kanjidicdep")
  directory kanjidicdep_dir => data_dir

  kanjidicdep_jsonl = File.join(kanjidicdep_dir, "data.jsonl")

  desc "Build kanjidicdep data file"
  task build: %w[kanjidep:update kanjidic:update clean update]

  desc "Clean up kanjidicdep temporary files"
  task :clean

  update_dependencies = [
    "kanjidep:update",
    kanjidep_jsonl,
    "kanjidic:update",
    kanjidic_jsonl,
    kanjidicdep_dir
  ]

  desc "Update kanjidicdep data file"
  task update: update_dependencies do
    puts "Updating kanjidicdep ..."
    jsonl_reader = JD::JsonlReader.new
    kanjidep = File.open(kanjidep_jsonl) { |file| jsonl_reader.read(file) }
    kanjidic = File.open(kanjidic_jsonl) { |file| jsonl_reader.read(file) }
    File.open(kanjidicdep_jsonl, "w") do |kanjidicdep|
      JD::Kanjidicdep::Reader.read(kanjidic, kanjidep).each do |row|
        kanjidicdep.write(JSON.dump(row), "\n")
      end
    end
  end
end
