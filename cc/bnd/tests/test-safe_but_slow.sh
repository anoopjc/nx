#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_TESTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_TESTS_DIR}/../globals.sh"
# shellcheck source="${SCRIPT_TESTS_DIR}/../globals.sh"
source "${GLOBALS}"

main() {
    printf "Starting the test - safe_but_slow approach.\n"
    printf "%s\n" "${GREEN}${BLINK} Starting the test - safe_but_slow approach.${NORMAL}"
    start_timer

    setup_logging
    print_git_info "${SCRIPT_DIR}"

    bash "${SCRIPT_DIR}/ubvm-build_artifacts.sh"
    print_duration

    printf "%s\n" "${YELLOW}${BLINK} Waiting to distribute artifacts - safe_but_slow approach.${NORMAL}"
    sleep 5

    bash "${SCRIPT_DIR}/ubvm-distribute_artifacts.sh"
    print_duration

    stop_timer
    printf "%s\n" "${GREEN}Successfully completed the test - safe_but_slow approach.${NORMAL}"
}

main
set +ex
