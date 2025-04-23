# frozen_string_literal: true

namespace :jmdict do
  jmdict_url = "http://ftp.edrdg.org/pub/Nihongo/JMdict_e.gz"

  tmp_dir = ENV.fetch("TMP_DIR", "tmp")
  directory tmp_dir

  jmdict_xml = File.join(tmp_dir, "jmdict.xml")

  desc "Clean up jmdict temporary files"
  task :clean do
    rm_rf jmdict_xml
  end

  desc "Download jmdict"
  task download: tmp_dir do
    puts "Downloading jmdict ..."
    URI.parse(jmdict_url).open do |stream|
      Zlib::GzipReader.open(stream) do |gz|
        IO.copy_stream(gz, jmdict_xml)
      end
    end
  end
end
