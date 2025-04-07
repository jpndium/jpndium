# frozen_string_literal: true

Dir.glob("lib/**/*.rake").each { |path| load path }

data_modules = %w[chiseids kanjidep kanjidic]

task default: :build

desc "Build all data files"
task build: %i[clean update]

desc "Clean up temporary files"
task clean: data_modules.map { |name| "#{name}:clean" }

desc "Update all data files"
task update: data_modules.map { |name| "#{name}:update" }
