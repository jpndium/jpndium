# frozen_string_literal: true

require "json"
require_relative "reader"

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
    reader = JD::Kanjidep::Reader.new
    File.open(kanjidep_jsonl, "w") do |kanjidep|
      reader.from_chiseids(chiseids_jsonl).each do |row|
        kanjidep.write(JSON.dump(row), "\n")
      end
    end
  end
end
