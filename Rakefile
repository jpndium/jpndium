# frozen_string_literal: true

Dir.glob("lib/**/*.rake").each { |path| load path }

task default: :build

desc "Clean up all files"
task clean: %w[kanjidic:clean]

desc "Build all files"
task build: %w[kanjidic:build]
