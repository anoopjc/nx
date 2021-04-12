#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

main() {
    print_commit_id
    source_ubvm_common
    transfer_bndscripts_to_cvm
    transfer_ccfiles_to_cvm
    cvm-extract_tarred_eggs
    cvm-deploy_eggs_to_all_cvms
}

main
set +ex
