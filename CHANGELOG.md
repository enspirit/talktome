## 1.3.4 - 2021-12-07

* Add support for configurable attachment content encoding.

## 1.3.3 - 2021-12-07

* Add support for attachments.

## 1.3.2 - 2021-12-05

* Add support for In-Reply-To.

## 1.3.1 - 2021-06-11

* POSTing to an existing email template route correctly returns a 404.

## 1.3.0 - 2021/05/31

* Add support for subfolders in Talktome Sinatra default App.

## 1.2.0 - 2021/05/05

* Add support for a TALKTOME_LAYOUTS_FOLDER environment variable used
  in auto_options. When set, the folder is used to embed formatted emails
  in more general layouts (see Client::Local.templater).

* Add support for sending an email to a specific user using a :to entry
  in WebApp api, provided an known secret is provided as Bearer token
  (for security reason). That allows using Talktome's docker image as a
  way to send emails to anyone securely.

## 1.1.0 - 2021/04/23

* Allows the use of environment variables to define subject and footer.

* The Mustache variables now include an `info` entry with all key/value
  pairs received on api endpoint. Useful for generic emails.

## 1.0.0 - 2021/04/20

* Add a Sinatra app.rb and docker image to send emails easily
  via environment variables and templates only. Useful for website
  contact forms.

## 0.3.0 - 2021/03/26

* Update dependencies. Path version must be >= 2.0, which may
  force dependent projects to upgrade too.

* Add travis to check for multi build matrices.

## 0.2.0 - 2019/03/20

* Weaken non-critical dependencies (mustache, path, redcarpet) to avoid unnecessary
  integration issues.

* A strategy now yields the block passed at `Client#talktome` with the strategy
  concrete message asset. The Email strategy for instance yields a Mail instance.
  This provides a chance to fix a few details on sending.

* Clients can now be instantiated without options, default options will be
  infered from environment variables.

## 0.1.0 - A long time ago

Birthday
