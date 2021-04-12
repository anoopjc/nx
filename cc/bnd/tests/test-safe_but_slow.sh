#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_TESTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_TESTS_DIR}/../globals.sh"
# shellcheck source="${SCRIPT_TESTS_DIR}/../globals.sh"
source "${GLOBALS}"

main() {
    printf "Starting the test - safe_but_slow approach."
    bash "${SCRIPT_DIR}/ubvm-build_artifacts.sh"
    sleep 5
    bash "${SCRIPT_DIR}/ubvm-distribute_artifacts.sh"
    printf "Successfully completed the test - safe_but_slow approach."
}

main
set +ex
