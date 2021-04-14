# Talktome - Talk to users easily

[![Build Status](https://travis-ci.com/enspirit/talktome.svg?branch=master)](https://travis-ci.com/enspirit/talktome)

## Run with docker

1. Build the image: `docker build -t talktome .`

or

`make image`

2. Run the image as a container: `docker run --rm -p 80:4567 talktome`

or

`make up`

## Run the tests

`TALKTOME_EMAIL_DEFAULT_FROM=from@talktome.com bundle exec rake`

or

`make test`

## Use talktome as the endpoint of a contact form

1. At the root folder of your project create a `talktome/Dockerfile` with this content:

    ```
    FROM enspirit/talktome:latest
    ```

2. Set the "from" email as an environment variable, i.e.: `TALKTOME_EMAIL_DEFAULT_FROM=john.doe@example.com`

3. If you want to use your own email template (optional, if you don't do this step the default email will be sent):  

    3.1 create these folders and file

        ```bash
        .
        ├── talktome
            ├── mail-templates
                ├── contact-us
                    ├── email.md
        ```

    3.2 Modify the `email.md` file at will

    3.3 Add this line to the `Dockerfile`

        ```
        COPY ./mail-templates /app/talktome/
        ```
