JITSI_MEET_VERSION ?=	7993
ALPINE_VERSION ?=	3.19

CPROG ?=		podman
CMD ?=

COMPONENTS=		\
	base \
	base-java \
	jitsi-meet \
	jibri \
	jicofo \
	jigasi \
	jitsi-autoscaler-sidecar \
	jitsi-videobridge
SOFTWARE=		jitsi-meet-prosody
APK_BUILD_TARGETS=	fetch unpack build checksum

IMAGES =		$(BASE_IMAGE) $(addprefix jitsi/,$(addsuffix -devel,$(COMPONENTS)))
BUILD_IMAGES=		$(addprefix build/,$(IMAGES)) apk-build

BUILD_SOFTWARE=		$(addprefix apk-build/,$(SOFTWARE))

all: $(BUILD_IMAGES)
$(BUILD_IMAGES):
	$(CPROG) build --rm --tag $(@:build/%=%) --target $(@:build/jitsi/%=%) \
		--ulimit nofile=5000:5000 \
		-f $(CURDIR)/Dockerfile.alpine

$(CURDIR)/work $(CURDIR)/work/src:
	mkdir -p $@
$(BUILD_SOFTWARE): | $(CURDIR)/work $(CURDIR)/work/src
	$(CPROG) run -ti --rm --volume $(CURDIR)/$(@:apk-build/%=%)/APKBUILD:/home/devel/APKBUILD:ro \
		--volume $(CURDIR)/work:/home/devel/packages:rw \
		apk-build $(CMD)
#		--volume $(HOME)/.ssh/id_rsa:/home/devel/.ssh/id_rsa:ro \
#		--volume $(HOME)/.ssh/id_rsa.pub:/home/devel/.ssh/id_rsa.pub:ro \

