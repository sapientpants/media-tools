#!/usr/bin/env bats


TMP_GENERATION_DIR="${BATS_TEST_DIRNAME}/tmp"
export TMP_GENERATION_DIR

[ -n "${DOCKER_IMAGE_NAME_TO_TEST}" ] || export DOCKER_IMAGE_NAME_TO_TEST=sapientpants/media-tools

setup() {
  if [ "${BATS_TEST_NUMBER}" = 1 ]; then
    echo "# Testing ${DOCKER_IMAGE_NAME_TO_TEST}" >&3
  fi
}

@test "We can build successfully the standard Docker image" {
  docker build -t "${DOCKER_IMAGE_NAME_TO_TEST}" "${BATS_TEST_DIRNAME}/../"
}
