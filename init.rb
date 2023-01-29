# frozen_string_literal: true

# r5 remove requires for zeitwork
# require 'redmine'
# require 'email_configurations_hooks'

if RUBY_VERSION < '2.2.2'
  ruby_version_error = '*** error redmine_email_fetcher: This plugin was not installed, '\
  'since it requires a Ruby version equal or higher than 2.2.2. Your Ruby version '\
  "is #{RUBY_VERSION})"

  puts ruby_version_error

elsif Rails::VERSION::MAJOR < 5
  rails_version_error = '*** error redmine_email_fetcher: This plugin was not installed, '\
  'since it requires a Rails version equal or higher than 5. Your Rails version '\
  "is #{Rails::VERSION::MAJOR})"

  puts rails_version_error

else
  Redmine::Plugin.register :redmine_email_fetcher do
    name 'Redmine Email Fetcher'
    author 'Bruce Pieterse'
    description 'Allows the configuration of several IMAP and POP3 email accounts'\
    'from where emails can be retrieved.'
    version '1.0.0'
    url 'https://github.com/octoquad/redmine_email_fetcher'
    author_url 'https://github.com/octoquad'
    requires_redmine version_or_higher: '4.0.0'

    menu :admin_menu,
         :email_configurations,
         { controller: 'email_configurations', action: 'index' },
         html: {
           class: 'icon'
         },
         caption: :title_email_configurations
  end
end
