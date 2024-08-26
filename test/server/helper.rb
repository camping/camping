# frozen_string_literal: true

$:.unshift(File.expand_path('../lib', __dir__))

require_relative '../../lib/camping'
require_relative '../../lib/camping/server'

require 'minitest/global_expectations/autorun'
require 'stringio'

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
