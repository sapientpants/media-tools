DOCKERHUB_USERNAME ?= sapientpants
DOCKER_IMAGE_NAME ?= media-tools
CURRENT_GIT_REF ?= $(shell git rev-parse --abbrev-ref HEAD) # Default to current branch
DOCKER_IMAGE_TAG ?= $(shell echo $(CURRENT_GIT_REF) | sed 's/\//-/' )
DOCKER_IMAGE_NAME_TO_TEST ?= $(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

export DOCKER_IMAGE_NAME_TO_TEST

all: build test

build:
	docker build \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)" \
		--file=Dockerfile \
		$(CURDIR)/

clean-build:
	docker build \
		--no-cache \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)" \
		--file=Dockerfile \
		$(CURDIR)/

shell: build
	docker run -it -v $(CURDIR)/tests/fixtures:/fixtures/ $(DOCKER_IMAGE_NAME_TO_TEST)

test:
	bats $(CURDIR)/tests/*.bats

deploy:
ifdef DOCKERHUB_TRIGGER_URL
ifeq ($(TRAVIS_BRANCH),main)
	curl -X POST ${DOCKERHUB_TRIGGER_URL}
else
	@echo "Skipping deployment for $(TRAVIS_BRANCH)"
endif
else
	@echo 'Unable to deploy: Please define $$DOCKERHUB_TRIGGER_URL'
endif

.PHONY: all build clean-build test shell deploy
