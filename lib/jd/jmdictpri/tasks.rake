# frozen_string_literal: true

namespace :jmdictpri do
  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  jmdict_dir = File.join(data_dir, "jmdict")
  directory jmdict_dir => data_dir

  jmdict_data_dir = File.join(jmdict_dir, "data")
  directory jmdict_data_dir => jmdict_dir

  jmdictpri_dir = File.join(data_dir, "jmdictpri")
  directory jmdictpri_dir => data_dir

  jmdictpri_jsonl = File.join(jmdictpri_dir, "data.jsonl")

  desc "Build jmdictpri data file"
  task build: %w[clean update]

  desc "Clean up jmdictpri temporary files"
  task :clean

  desc "Update jmdictpri data file"
  task update: ["jmdict:update", jmdict_data_dir, jmdictpri_dir] do
    puts "Updating jmdictpri ..."
    JD::JsonlWriter.open(jmdictpri_jsonl) do |jmdictpri|
      write = jmdictpri.method(:write)
      JD::Jmdict::PriorityReader.read(jmdict_data_dir, &write)
    end
  end
end
