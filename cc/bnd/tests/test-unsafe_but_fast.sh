#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_TESTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_TESTS_DIR}/../globals.sh"
# shellcheck source="${SCRIPT_TESTS_DIR}/../globals.sh"
source "${GLOBALS}"

main() {
    printf "Starting the test - test-unsafe_but_fast approach.\n"
    start_timer

    setup_logging
    print_git_info "${SCRIPT_DIR}"

    bash "${SCRIPT_DIR}/ubvm-create_ccfiles_list.sh"
    print_duration

    bash "${SCRIPT_DIR}/ubvm-distribute_scripts.sh"
    print_duration

    rm -f "${SRC_CHANGED_FILES_LIST}"

    stop_timer
    printf "Successfully completed the test - test-unsafe_but_fast approach.\n"
}

main
set +ex
