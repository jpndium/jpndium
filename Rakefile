# frozen_string_literal: true

require "json"
require "open-uri"
require "zlib"
require_relative "lib/jd"

Dir.glob("lib/**/*.rake").each { |path| load path }

data_modules = %w[
  chiseids jmdict jmdictpri jmnedictpri kanjidep kanjidic kanjidicdep
]

task default: :build

desc "Build all data files"
task build: %i[clean update]

desc "Clean up temporary files"
task clean: data_modules.map { |name| "#{name}:clean" }

desc "Update all data files"
task update: data_modules.map { |name| "#{name}:update" }
