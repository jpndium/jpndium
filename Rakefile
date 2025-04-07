# frozen_string_literal: true

Dir.glob("lib/**/*.rake").each { |path| load path }

task default: :build

desc "Clean up temporary files"
task clean: %w[chiseids:clean kanjidep:clean kanjidic:clean]

desc "Build all data files"
task build: %w[chiseids:build kanjidep:build kanjidic:build]
