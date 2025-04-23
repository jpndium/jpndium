# frozen_string_literal: true

require "json"
require "nokogiri"

Dir.glob("jd/**/*.rb", base: File.dirname(__FILE__))
  .each { |path| require_relative path }
