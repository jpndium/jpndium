# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "spec"
end

require "jd"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # Create custom descriptions from expectation chains
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Methods that do not exist cannot be stubbed
    mocks.verify_partial_doubles = true
  end

  # Inherit host example/group metadata
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Temporarily focus an example/group by tagging it with the :focus metadata
  config.filter_run_when_matching :focus

  # Persist state between runs
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Enable zero monkey patching mode
  config.disable_monkey_patching!

  # Enable warnings
  config.warnings = true

  # Use more verbose output when running an individual spec
  config.default_formatter = "doc" if config.files_to_run.one?

  # Run specs in random order
  config.order = :random

  # Allow setting global seed via `--seed` CLI option
  Kernel.srand config.seed
end
