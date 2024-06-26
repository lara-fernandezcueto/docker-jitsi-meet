FORCE_REBUILD ?= 0
JITSI_RELEASE ?= stable
JITSI_BUILD ?= unstable
JITSI_REPO ?= jitsi

BASE_OS ?= debian

JITSI_SERVICES := base base-java web prosody jicofo jvb jigasi jibri

BUILD_ARGS := \
	--build-arg JITSI_REPO=$(JITSI_REPO) \
	--build-arg BASE_TAG=$(JITSI_BUILD) \
	--build-arg JITSI_RELEASE=$(JITSI_RELEASE)

ifeq ($(FORCE_REBUILD), 1)
  BUILD_ARGS := $(BUILD_ARGS) --no-cache
endif

all: build-all

ifeq ($(BASE_OS), alpine)
.PHONY:	devel
devel:
	$(MAKE) -C devel

build: devel
endif

release:
	@$(foreach SERVICE, $(JITSI_SERVICES), $(MAKE) --no-print-directory JITSI_SERVICE=$(SERVICE) buildx;)

buildx:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--progress=plain \
		$(BUILD_ARGS) --build-arg BASE_TAG=$(JITSI_BUILD) \
		--pull --push \
		--tag $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_BUILD) \
		--tag $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_RELEASE) \
		--file $(JITSI_SERVICE)/Dockerfile.$(BASE_OS)

$(addprefix buildx_,$(JITSI_SERVICES)):
	$(MAKE) --no-print-directory JITSI_SERVICE=$(patsubst buildx_%,%,$@) buildx

build:
	docker build \
		$(BUILD_ARGS) \
		--progress plain \
		--tag $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_BUILD) \
		--file $(JITSI_SERVICE)/Dockerfile.$(BASE_OS)

$(addprefix build_,$(JITSI_SERVICES)):
	$(MAKE) --no-print-directory JITSI_SERVICE=$(patsubst build_%,%,$@) build

tag:
	docker tag $(JITSI_REPO)/$(JITSI_SERVICE) $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_BUILD)

push:
	docker push $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_BUILD)

%-all:
	@$(foreach SERVICE, $(JITSI_SERVICES), $(MAKE) --no-print-directory JITSI_SERVICE=$(SERVICE) $(subst -all,;,$@))

clean:
	docker-compose stop
	docker-compose rm
	docker network prune

prepare:
	FORCE_REBUILD=1 $(MAKE)

.PHONY: all build tag push clean prepare release $(addprefix build_,$(JITSI_SERVICES))
