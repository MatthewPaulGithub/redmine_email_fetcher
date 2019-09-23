# frozen_string_literal: true

# ApplicationRecord is a new superclass for all app models, analogous to app controllers subclassing
# ApplicationController instead of ActionController::Base.
# This gives apps a single spot to configure app-wide model behavior.
# See: https://guides.rubyonrails.org/v5.2/upgrading_ruby_on_rails.html#active-record-models-now-inherit-from-applicationrecord-by-default
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
