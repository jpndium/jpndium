# frozen_string_literal: true

desc "Tokenize Japanese text"
task :tokenize do
  JD::Tokenizer.tokenize($stdin) do |row|
    puts JSON.dump(row)
  end
end

desc "Tokenize Japanese text ignoring duplicate tokens"
task :tokenize_unique do
  JD::Tokenizer.tokenize($stdin, unique: true) do |row|
    puts JSON.dump(row)
  end
end
