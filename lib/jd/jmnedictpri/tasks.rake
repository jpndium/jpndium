# frozen_string_literal: true

require "json"
require "open-uri"
require "zlib"
require_relative "reader"

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
    reader = JD::Jmnedictpri::Reader.new
    File.open(jmnedictpri_jsonl, "w") do |jmnedictpri|
      reader.read_file(jmnedict_xml) do |row|
        jmnedictpri.write(JSON.dump(row), "\n")
      end
    end
  end
end
