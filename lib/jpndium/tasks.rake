# frozen_string_literal: true

desc "Tokenize Japanese text"
task :tokenize do
  Jpndium.tokenize($stdin) do |row|
    puts JSON.dump(row)
  end
end

desc "Tokenize Japanese text ignoring duplicate tokens"
task :tokenize_unique do
  Jpndium.tokenize_unique($stdin) do |row|
    puts JSON.dump(row)
  end
end
