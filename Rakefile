# frozen_string_literal: true

require "json"
require "open-uri"
require "zlib"
require_relative "lib/jpndium"

Dir.glob("lib/**/*.rake").each { |path| load path }

data_modules = %w[
  chiseids
  chiseids:dep
  jmdict
  jmdict:dep
  jmnedict
  jmnedict:dep
  kanjidic
  kanjidic:dep
]

task default: :build

desc "Build all data files"
task build: data_modules.map { |name| "#{name}:build" }

desc "Clean up temporary files"
task clean: data_modules.map { |name| "#{name}:clean" }

desc "Update all data files"
task update: data_modules.map { |name| "#{name}:update" }
