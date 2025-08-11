# Talktome - Talk to users easily

[![Build Status](https://travis-ci.com/enspirit/talktome.svg?branch=master)](https://travis-ci.com/enspirit/talktome)

Talktome helps talking to users (by email for now, but later we aim to add support
for various notification systems) easily. As a ruby gem to be used programmatically,
or as a docker container exposing web services (different use cases, see below).

## Using Talktome programmatically

Using Talktome programmatically is useful to send transactional emails to users.

```
require 'talktome'
CLIENT = Talktome::Client::Local.new(path_to_templates)

# later on
CLIENT.talktome(template_name, user, template_info, strategies)

# typically, the will send an email to foo@bar.com instantiating
# the email found in path_to_templates/hello/email.md and
# instantiated using mustache and markdown
CLIENT.talktome("hello", {email: 'foo@bar.com'}, {}, [:email])
```

## Using Talktome using the docker image

The docker image aims at supporting another category of use cases, such as providing
a reusable backend for contact forms.

```
docker run \
    -p 3000:3000 \
    -e TALKTOME_EMAIL_DEFAULT_FROM=info@mydomain.com
    -e TALKTOME_EMAIL_DEFAULT_TO=support@mydomain.com
    enspirit/talktome
```

Send an contact-us email through the web api using curl, as follows:

```
curl -XPOST \
     -H'Content-Type: application/json' \
     -d'{"reply_to": "someone@foo.bar", "message": "Hello"}' \
     http://127.0.0.1:3000/contact-us/
```

This web API does not allow specifying `from` and `to` as input data to avoid
exposing a way to send SPAM easily.

### Overriding templates (and having more than one endpoint)

The default image comes with a single contact-us email template used by Enspirit.
Feel free to override it by providing one or more email templates.

You can mount a volume with email templates into `/app/templates/`, which will
be used for the available endpoints. For instance, the following `templates/`
folder will expose two endpoints with possibly different behaviors (according
to the templates themselves):

```
templates/
  contact-us/
    email.md
  report-issue/
    email.md
```

Two usual ways to do so in docker: commandline or Dockerfile. On commandline,
use the following option:

```
-v ${PWD}/my-templates:/app/templates
```

In a Dockerfile, add your templates:

```
FROM enspirit/talktome

COPY ./templates /app/templates
```

## Configuring Talktome

The easiest way to configure Talktome is through environment variables. The following
ones are supported:

```
TALKTOME_DEBUG                      when set enables the dumping of sent messages to ./tmp folder

TALKTOME_EMAIL_DELIVERY             smtp, file or test (see ruby Mail library)
TALKTOME_EMAIL_DEFAULT_FROM         default From: to use for email sending
TALKTOME_EMAIL_DEFAULT_REPLYTO      default Reply-To: to use for email sending
TALKTOME_EMAIL_DEFAULT_TO           default To: to use for email sending

TALKTOME_EMAIL_SUBJECT              Set the subject of the default "contact us" email
TALKTOME_EMAIL_FOOTER               Set the footer of the default "contact us" email

TALKTOME_LAYOUTS_FOLDER             Set the folder to use for messaging layouts

TALKTOME_SMTP_ADDRESS               host address for smtp sending
TALKTOME_SMTP_PORT                  port of smtp server to use
TALKTOME_SMTP_DOMAIN                sending domain
TALKTOME_SMTP_USER                  user for smtp authentication
TALKTOME_SMTP_PASSWORD              password for smtp authentication
TALKTOME_SMTP_AUTHENTICATION        smtp authentication method (plain, login, cram-md5, ...)
TALKTOME_SMTP_STARTTLS_AUTO         true or false (see ruby Mail library)
TALKTOME_SMTP_OPENSSL_VERIFY_MODE   none or peer (see ruby Mail library). Defaults to peer.

TALKTOME_BEARER_SECRET              secret for the webapi, to let send emails to anyone

RACK_KEY_SPACE_LIMIT                configures the max key space limit for the rack query parser
```

## Hacking Talktome

In pure Ruby:

```
bundle install
bundle exec rake test
```

Or using docker, please then use the `make` targets initially cooked for Jenkins:

```
make image
make test
```

## Contributing

Please use github issues for questions and bugs, and pull requests for
submitting improvement proposals and new features.

## Contributors

Enspirit (https://enspirit.be) and Klaro App (https://klaro.cards) are
both actively using, contributing and funding work on this library.
Please contact Bernard Lambeau for any question.

## Licence

Webspicy is distributed under a MIT Licence, by Enspirit SRL.
