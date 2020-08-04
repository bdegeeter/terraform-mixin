#!/usr/bin/env bash

set -euo pipefail
export REGISTRY=${REGISTRY:-$USER}
export REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
export PORTER_HOME=${PORTER_HOME:-$REPO_DIR/bin}
# Run tests in a temp directory
export TEST_DIR=/tmp/porter/terraform
mkdir -p ${TEST_DIR}
pushd ${TEST_DIR}
trap popd EXIT

# Copy terraform assets
cp -r ${REPO_DIR}/build/testdata/bundles/terraform/terraform .

# Copy in the terraform porter manifest
cp ${REPO_DIR}/build/testdata/bundles/terraform/porter.yaml .

${PORTER_HOME}/porter build

${PORTER_HOME}/porter install --debug --param file_contents='foo!'

echo "Verifying installation output(s) via 'porter installation outputs list' after install"
list_outputs=$(${PORTER_HOME}/porter installation outputs list)
echo "${list_outputs}"
echo "${list_outputs}" | grep -q "file_contents"
echo "${list_outputs}" | grep -q "foo!"

${PORTER_HOME}/porter invoke --action=plan --debug

${PORTER_HOME}/porter upgrade --debug --param file_contents='bar!'

echo "Verifying installation output(s) via 'porter installation output show' after upgrade"
${PORTER_HOME}/porter installation output show file_contents | grep -q "bar!"

${PORTER_HOME}/porter uninstall --debug
