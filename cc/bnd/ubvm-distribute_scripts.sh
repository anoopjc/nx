#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

get_ubvm_common() {
    # shellcheck source="${SCRIPT_DIR}/ubvm-common.sh"
    source "${UBVM_COMMON_SCRIPT}"
}

main() {
    get_ubvm_common
    transfer_bndscripts_to_cvm
    scp_ccscripts_to_cvm
    cvm-extract_eggs
    cvm-deploy_eggs_to_all_cvms
}

main
set +ex
