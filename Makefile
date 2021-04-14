IMAGE = enspirit/talktome
SHELL=/bin/bash -o pipefail
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

################################################################################
### Config variables
###

# Load them from an optional .env file
-include .env

# Specify which docker tag is to be used
DOCKER_TAG := $(or ${DOCKER_TAG},${DOCKER_TAG},latest)

################################################################################
### Main docker rules
###

clean:
	rm -rf pkg/
	rm -rf Dockerfile.log Dockerfile.built Dockerfile.pushed

Dockerfile.built: Dockerfile $(shell git ls-files)
	docker build -t $(IMAGE) . | tee Dockerfile.log
	touch Dockerfile.built

Dockerfile.pushed: Dockerfile.built
	@if [ -z "$(DOCKER_REGISTRY)" ]; then \
		echo "No private registry defined, ignoring. (set DOCKER_REGISTRY or place it in .env file)"; \
		return 1; \
	fi
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(DOCKER_TAG) | tee -a Dockerfile.log
	touch Dockerfile.pushed

image: Dockerfile.built
push-image: Dockerfile.pushed

################################################################################
### Main development rules
###

Gemfile.lock: Gemfile
	bundle install

up: Dockerfile.built
	docker run --rm -p 80:4567 $(IMAGE)
