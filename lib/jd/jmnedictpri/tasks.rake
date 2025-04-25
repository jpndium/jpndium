# frozen_string_literal: true

namespace :jmnedictpri do
  tmp_dir = ENV.fetch("TMP_DIR", "tmp")

  jmnedict_xml = File.join(tmp_dir, "jmnedict.xml")
  file jmnedict_xml

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  jmnedictpri_dir = File.join(data_dir, "jmnedictpri")
  directory jmnedictpri_dir => data_dir

  jmnedictpri_jsonl = File.join(jmnedictpri_dir, "data.jsonl")

  desc "Build jmnedictpri data file"
  task build: %w[clean update]

  desc "Clean up jmnedictpri temporary files"
  task clean: %w[jmnedict:clean]

  desc "Update jmnedictpri data file"
  task update: ["jmnedict:download", jmnedict_xml, jmnedictpri_dir] do
    puts "Updating jmnedictpri ..."
    JD::JsonlWriter.open(jmnedictpri_jsonl) do |jmnedictpri|
      write = jmnedictpri.method(:write)
      JD::Jmnedictpri::Reader.read_file(jmnedict_xml, &write)
    end
  end
end
