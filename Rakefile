# frozen_string_literal: true

Dir.glob("lib/**/*.rake").each { |path| load path }

task default: :build

data_modules = %w[chiseids kanjidep kanjidic]

desc "Clean up temporary files"
task clean: data_modules.map { |name| "#{name}:clean" }

desc "Build all data files"
task build: [:clean, *data_modules.map { |name| "#{name}:build" }]
