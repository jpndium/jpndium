# frozen_string_literal: true

namespace :jmnedictpri do
  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  jmnedict_dir = File.join(data_dir, "jmnedict")
  directory jmnedict_dir => data_dir

  jmnedict_data_dir = File.join(jmnedict_dir, "data")
  directory jmnedict_data_dir => jmnedict_dir

  jmnedictpri_dir = File.join(data_dir, "jmnedictpri")
  directory jmnedictpri_dir => data_dir

  jmnedictpri_jsonl = File.join(jmnedictpri_dir, "data.jsonl")

  desc "Build jmnedictpri data file"
  task build: %w[clean update]

  desc "Clean up jmnedictpri temporary files"
  task :clean

  desc "Update jmnedictpri data file"
  task update: ["jmnedict:update", jmnedict_data_dir, jmnedictpri_dir] do
    puts "Updating jmnedictpri ..."
    JD::JsonlWriter.open(jmnedictpri_jsonl) do |jmnedictpri|
      write = jmnedictpri.method(:write)
      JD::Jmnedict::PriorityReader.read(jmnedict_data_dir, &write)
    end
  end
end
