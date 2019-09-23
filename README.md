# Redmine Email Fetcher

This Redmine plugin extends the
[Redmine receiving emails](https://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails#Fetching-emails-from-a-POP3-server)
functionality by allowing the configuration of multiple email accounts 
and fetching e-mails periodically.

## Features

* Stores IMAP and POP3 email configurations.
* Associate each email configuration with the desired project, tracker 
  and optionally with categories and priority.
* Allow manual email connection testing and fetching for each active 
  account.
* Provides a rake task which can be utilised in a cron job to fetch
  emails from all active email configurations periodically.
* Allows a configuration to be deactivated to stop email fetching with 
  Redmine.

## Requirements

* Ruby >= 2.2.2
* Rails >= 5.2.0
* Redmine >= 4.0.0
* Bundler >= 2.0.1

## Installation & Upgrade

Substitute `#{RAILS_ROOT}` in this guide with the path to the root
directory of your Redmine installation directory e.g.
`/var/www/redmine/`.

Commands preceded with `$` do not need to be included when running the 
commands. `$` represents a normal user running a command compared to the
root (`#`) user. 

### Installation
If you downloaded this plugin as a tar ball or zip, copy the plugin into
`#{RAILS_ROOT}/plugins` e.g
`/var/www/redmine/plugins/redmine_email_fetcher`.

If you are downloading the plugin directly from GitHub, you can do so 
by changing into the `#{RAILS_ROOT}/plugins` directory and run:

```shell
$ git clone git://github.com/octoquad/redmine_email_fetcher.git
```

### Upgrade
If you downloaded this plugin as a tar ball or zip, backup and then 
replace the old plugin directory with the new plugin directory.

If you are downloading the plugin directly from GitHub, you can update
by changing into the plugin directory and run `git pull`.

### Common Install and Upgrade Steps

1. Install or update the ruby gems by changing into `#{RAILS_ROOT}`
   directory and run the following command:
   ```shell
   $ bundle install --without development test
   ```
2. Install the plugin by running the following command in
   `#{RAILS_ROOT}`. If upgrading, ensure that you made a backup of the
   Redmine database:
   ```shell
   $ rake redmine:plugins:migrate RAILS_ENV=production
   ```

3. In `#{RAILS_ROOT}` run the following command.
   ```shell
   $ rake -T redmine:plugins:email_fetcher RAILS_ENV=production
   ```
   If the installation/upgrade was successful you should now see the list of
   [Rake Tasks](#rake-tasks).

4. Restart Redmine.

You should now be able to see **Redmine Email Fetcher** listed among the
plugins in `Administration > Plugins` and **Fetch emails** under the
`Administration` section.

### Uninstall
:warning: Ensure that you have made a backup of the Redmine database
before proceeding.

1. Navigate to `#{RAILS_ROOT}` and run the following command to remove
   the database table and configuration data.
   ```shell
   $ rake redmine:plugins:migrate NAME=email_fetcher VERSION=0 RAILS_ENV=production
   ```

2. Remove the plugin from the `plugins` folder.
3. Restart Redmine.


## Configuration

Navigate to `Administration > Fetch emails` to access the plugin
configuration.

### Configuration attributes
+ **Protocol**: Sets the e-mail account protocol to use. Either **IMAP**
  or **POP3**.
+ **Active**: Specify if this email account is active and should be used
  to retrieve unprocessed e-mails.
+ **Fetched**: Date and time the last successful retrieval of mail 
  occurred.
  
### Email attributes
+ **Host**: The server host e.g. `127.0.0.1`.
+ **Port**: The server port e.g. `993`.
+ **SSL/TLS**: Whether SSL/TLS is used for this account.
+ **Email username**: The email account username e.g.
  `redmine@domain.com`.
+ **Email password**: The email account password.
+ **Folder name**: The email folder name where emails should be
  retrieved. 
  - **IMAP**: Any folder name is possible, but the test function will
    validate that this folder is reachable after login e.g. `REDMINE`
    `UNPROCESSED` etc.
  - **POP3**: Since this is an old protocol, only the `INBOX` folder is
    allowed.
    
#### IMAP Specific
+ **On success move to folder**: This optional IMAP option allows
  configuration of where successfully retrieved emails should be moved
  to instead of deleting them e.g. `ARCHIVE`, `PROCESSED` etc.
+ **On failure move to folder**: This optional IMAP option allows
  configuration of where ignored emails should be moved e.g. `IGNORED`.
#### POP3 Specific
+ **Use APOP**: This optional POP3 option allows specifying if APOP
  authentication should be used. Default is `false`.
+ **On failure delete email**: This optional POP3 option allows
  specifying whether emails, which could not be processed successfully,
  are deleted from the server. Default is `false` which leaves them on
  the server).

### Unknown sender actions

The following applies to Redmine once e-mails have been retrieved.

+ **Method for unknown users** - How to handle emails from an unknown
  user:
  - **accept**: The sender is considered as an anonymous user and the
    email is accepted (default). If you choose this option you must
    activate the Custom field `owner-email`, where the sender email
    address will be stored. Without this field activated, the email
    fetching will fail, since this information is required to send
    information back to the sender. The
    [Redmine Helpdesk plugin](https://github.com/jfqd/redmine_helpdesk)
    might be a nice addition.
  - **ignore**: The email is ignored.
  - **create**: A user account is created for the sender and the email
    is accepted. A username and password is sent back to the user.
+ **Use no_account_notice**: Suppress account generation notification.
  This is used in conjuction with the option above and the **create**
  option. Default is `False`.
+ **Use no_permission_check**: Disable permission checking when
  receiving the email. Default is `True`.
+ **Default group for new reporters**: Automatically add new users to
  one or more groups e.g. `group1,group2` (optional).

### Default issue creation attributes:

The following applies to Redmine once e-mails have been retrieved and no
issue specific e-mail body attributes were provided. See [Redmine Issue
Attributes](https://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails#Issue-attributes)
for information.

:warning: The **Category name** and **Priority name** are free text, so
if you update their names it is your responsibility to update them
accordingly in the Redmine E-mail Fetcher configuration.

+ **Tracker**: Default tracker
+ **Category name**: Name of the default category (optional)
+ **Priority name**: Name of the default priority (optional)
+ **allow_override**: Allow email content to override attributes
  specified by previous options attributes. This is a comma-separated
  list of attributes e.g. `project,tracker,category,priority` (optional)
+ **Project**: Default project for new issues

## Rake task

You can use the `redmine:plugins:email_fetcher:fetch_all_emails` rake
task to periodically fetch e-mails from all active configured accounts.

```shell 
*/5 * * * * www-data /usr/bin/rake -f /opt/redmine/Rakefile --silent redmine:plugins:email_fetcher:fetch_all_emails RAILS_ENV=production 2>&- 1>&- 
```

If you running under a dedicated user account you can use the following:

```shell
*/5 * * * *   /usr/local/bin/bundle exec /usr/local/bin/rake -f /path/to/redmine/Rakefile --silent redmine:plugins:email_fetcher:fetch_all_emails RAILS_ENV=production 2>&- 1>&-
```
 
The tasks recognize three environment variables:
+ **DRY_RUN**: Performs a run without changing the database.
+ **LOG_LEVEL**: Controls the rake task verbosity. The possible values
  are:
  - **silent**: Nothing is written to the output.
  - **error**: Only errors are written to the output.
  - **change**: Only writes errors and changes made to the user/group's base.
  - **debug**: Detailed information about the execution is visible to help
               identify errors. This is the default value.

## Troubleshooting

### OpenSSL
The plugin is prepared and intended to run with any IMAP and POP3 email 
account, however some issues can occur due to security certificates.

When using SSL, please check that the machine has the proper 
certificates installed by running the following terminal commands:

```shell
$ openssl
```

```shell
$ s_client -connect HOST:PORT
```

## Contributing
Feel free to contribute by adding more features or solving existing
issues. All PR are very welcome.

After make your changes and before send the PR to the project, please validate that:

* Rubocop doesn't detect offenses and
* Tests are passing (tests need Redmine)

```shell
cd plugins/redmine_email_fetcher
bundle exec rubocop --auto-correct
RAILS_ENV=test rake db:drop db:create db:migrate
RAILS_ENV=test rake redmine:plugins:migrate
RAILS_ENV=test rake redmine:load_default_data
RAILS_ENV=test rake test TEST=plugins/redmine_email_fetcher/test/models/email_configuration_test.rb # or
RAILS_ENV=test bundle exec ruby -I test plugins/redmine_email_fetcher/test/models/email_configuration_test.rb
```
### Recognition of past maintainers

A big thank you to:
 
* [@luismaia](https://github.com/luismaia) for initially creating
  [this plugin](https://github.com/luismaia/redmine_email_fetcher) in
  2014\.
* [@Dikoy](https://github.com/Dikoy) and
  [@Arean82](https://github.com/Arean82) for fixing and making this
  plugin still useful after 2015.

## License 
This plugin is released under the GPLv3 license.

See LICENSE for more information.

The icon used under the administration section is from
[FamFamFam Silk Icons](http://www.famfamfam.com/lab/icons/silk/) and is
licensed under the Creative Commons Attribution 3.0 License.
