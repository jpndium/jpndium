# frozen_string_literal: true

namespace :jmdictpri do
  tmp_dir = ENV.fetch("TMP_DIR", "tmp")

  jmdict_xml = File.join(tmp_dir, "jmdict.xml")
  file jmdict_xml

  data_dir = ENV.fetch("DATA_DIR", "data")
  directory data_dir

  jmdictpri_dir = File.join(data_dir, "jmdictpri")
  directory jmdictpri_dir => data_dir

  jmdictpri_jsonl = File.join(jmdictpri_dir, "data.jsonl")

  desc "Build jmdictpri data file"
  task build: %w[clean update]

  desc "Clean up jmdictpri temporary files"
  task clean: %w[jmdict:clean]

  desc "Update jmdictpri data file"
  task update: ["jmdict:download", jmdict_xml, jmdictpri_dir] do
    puts "Updating jmdictpri ..."
    File.open(jmdictpri_jsonl, "w") do |jmdictpri|
      JD::Jmdictpri::Reader.read_file(jmdict_xml) do |row|
        jmdictpri.write(JSON.dump(row), "\n")
      end
    end
  end
end
