include ../Makevars

.PHONY: image image-upload

latest_commit = $(shell curl -s https://api.github.com/repos/PRL-PRG/$(1)/commits?sha=$(2) | jq -r '.[0].sha')

INJECTR_VERSION     ?= $(call latest_commit,injectr,master)
INSTRUMENTR_VERSION ?= $(call latest_commit,instrumentr,master)
RUNR_VERSION        ?= $(call latest_commit,runr,$(RUNR_GIT_BRANCH))

all: image

packages.txt:
	cat ../data/corpus.txt kaggle-dependencies.txt | sort | uniq > packages.txt

image: packages.txt
	docker build \
    --rm \
    --build-arg CRAN_MIRROR=$(CRAN_MIRROR) \
    --build-arg INJECTR_VERSION=$(INJECTR_VERSION) \
    --build-arg INSTRUMENTR_VERSION=$(INSTRUMENTR_VERSION) \
    --build-arg RUNR_VERSION=$(RUNR_VERSION) \
    -t $(DOCKER_IMAGE_NAME) \
    .

image-upload: image
	docker push $(DOCKER_IMAGE_NAME)
