# frozen_string_literal: true

require "json"
require_relative "reader"

namespace :kanjidep do
  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  chiseids_dir = File.join(data_dir, "chiseids")
  directory chiseids_dir => data_dir

  chiseids_jsonl = File.join(chiseids_dir, "data.jsonl")
  file chiseids_jsonl => chiseids_dir

  kanjidep_dir = File.join(data_dir, "kanjidep")
  directory kanjidep_dir => data_dir

  kanjidep_jsonl = File.join(kanjidep_dir, "data.jsonl")

  desc "Build kanjidep data file"
  task build: %w[chiseids:update update]

  desc "Update kanjidep data file"
  task update: [chiseids_jsonl, kanjidep_dir] do
    puts "Updating kanjidep ..."
    reader = JD::Kanjidep::Reader.new
    File.open(kanjidep_jsonl, "w") do |jsonl|
      reader.from_chiseids(chiseids_jsonl).each do |row|
        jsonl.write(JSON.dump(row), "\n")
      end
    end
  end
end
