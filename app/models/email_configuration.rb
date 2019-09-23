# frozen_string_literal: trueApplicationRecord

# EmailConfiguration Test class
class EmailConfiguration < ApplicationRecord
  include Redmine::SafeAttributes
  include EmailTests
  include EmailFetches

  unloadable

  belongs_to :project
  belongs_to :tracker

  validates :configuration_type, presence: true

  validates :host, presence: true
  validates :port, presence: true
  validates :unknown_user, presence: true
  validates :ssl, inclusion: { in: [true, false] }
  validates :username, presence: true
  validates :password, presence: true
  validates :folder, presence: true

  validates :project, presence: true
  validates :tracker, presence: true

  validates :delete_unprocessed, inclusion: { in: [true, false] }
  validates :apop, inclusion: { in: [true, false] }
  validates :no_account_notice, inclusion: { in: [true, false] }
  validates :no_permission_check, inclusion: { in: [true, false] }

  validates :folder, presence: true,
                     uniqueness: { scope: %i[host port username], message: l(:msg_unique_key_folder) }

  # SCOPES
  scope :active, lambda {
    where(flg_active: true)
  }

  # Static function to fetch all the emails from active email configurations
  def self.fetch_all_emails
    configurations = EmailConfiguration.active
    result_out = []

    configurations.each do |email_config|
      test_success, _message = email_config.test_and_fetch_emails

      message = "SUCCESS : #{email_config.log_msg}" if test_success
      message = "ERROR : #{email_config.log_msg}" unless test_success

      result_out << message
    end

    result_out
  end

  def log_msg
    msg = "Fetched '#{configuration_type.upcase}' account '#{username}' "\
      "(folder '#{folder}') at '#{host}':'#{port}'"
    msg
  end
end
