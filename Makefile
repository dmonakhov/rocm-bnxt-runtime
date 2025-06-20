# Image registry
IMAGE_NAME ?= rocm-bnxt-runtime
IMAGE_TAG  ?= test

# Build dependencies
BNXT_VERSION=232.0.164.5
BASE_IMAGE=rocm/dev-ubuntu-22.04:6.4.1-complete

# Export options
EXPORT_PATH ?= ..
ZSTD_COMPRESS_OPTIONS ?= --ultra -22

build:
	docker build --progress plain --rm \
		--tag "${IMAGE_NAME}:${IMAGE_TAG}" \
		--build-arg BASE_IMAGE=${BASE_IMAGE} \
		--build-arg BNXT_VERSION=${BNXT_VERSION} \
		-f Dockerfile .
build-dbg:
	docker build --progress plain --rm \
		--tag "${IMAGE_NAME}:dbg-${IMAGE_TAG}" \
		--build-arg BASE_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}" \
		-f Dockerfile.dbg .

tar-img:
	docker save \
		"${IMAGE_NAME}:${IMAGE_TAG}"  | \
		zstdmt ${ZSTD_COMPRESS_OPTIONS} -v -f -o ${EXPORT_PATH}/${IMAGE_NAME}-${IMAGE_TAG}.tar.zst

publish-img: build
	docker push "${IMAGE_NAME}:${IMAGE_TAG}"
