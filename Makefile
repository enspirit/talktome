IMAGE = enspirit/talktome
SHELL=/bin/bash -o pipefail
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

################################################################################
### Config variables
###

# Load them from an optional .env file
-include .env

# Specify which ruby version is used as base
DEFAULT_MRI_VERSION := 3.1
MRI_VERSION := $(or ${MRI_VERSION},${MRI_VERSION},$(DEFAULT_MRI_VERSION))

# Specify which docker tag is to be used
VERSION := $(or ${VERSION},${VERSION},latest)
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)
PLATFORMS := linux/amd64,linux/arm64/v8

TINY = ${VERSION}
MINOR = $(shell echo '${TINY}' | cut -f'1-2' -d'.')
MAJOR = $(shell echo '${MINOR}' | cut -f'1' -d'.')

$(info $(TINY) $(MINOR) $(MAJOR))

################################################################################
### Main docker rules
###

clean:
	rm -rf pkg/*
	rm -rf Dockerfile.log Dockerfile.built Dockerfile.pushed

Dockerfile.built: Dockerfile $(shell git ls-files)
	@docker buildx build -f Dockerfile ./ \
		--push \
		--build-arg MRI_VERSION=${MRI_VERSION} \
		--platform ${PLATFORMS} \
		-t $(DOCKER_REGISTRY)/enspirit/talktome \
		-t $(DOCKER_REGISTRY)/enspirit/talktome:${TINY} \
		-t $(DOCKER_REGISTRY)/enspirit/talktome:${MINOR} \
		-t $(DOCKER_REGISTRY)/enspirit/talktome:ruby${MRI_VERSION} \
		-t $(DOCKER_REGISTRY)/enspirit/talktome:$(TINY)-ruby${MRI_VERSION} \
		-t $(DOCKER_REGISTRY)/enspirit/talktome:$(MINOR)-ruby${MRI_VERSION}

	touch Dockerfile.built

.build/buildx.builder:
	mkdir -p .build
	docker buildx create --use --name talktome
	touch .build/buildx.builder

image: .build/buildx.builder Dockerfile.built

################################################################################
### Main development rules
###

bundle:
	bundle install

up: Dockerfile.built
	docker run -d -p 80:3000 $(IMAGE)

test: bundle
	bundle exec rake test

################################################################################
### Gem Management
###

gem: clean bundle
	bundle exec rake gem

gem.publish: gem
	gem push `ls -Art pkg/*.gem | tail -n 1`

gem.publish.ci:
	gem push `ls -Art pkg/*.gem | tail -n 1`
