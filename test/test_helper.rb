# frozen_string_literal: true

require 'simplecov'

# Coverage
SimpleCov.start

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

Rails.backtrace_cleaner.remove_silencers!

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                         [:email_configurations])
