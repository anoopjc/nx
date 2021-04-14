#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

create_ccfiles_list() {
    local ccfiles_list_file="${SRC_CHANGED_FILES_LIST}"
    local cc_dirs
    cc_dirs="$TOP/infra_server/cluster/py/cluster/genesis/convert_cluster"
    cc_dirs+=" $TOP/infra_client/infrastructure/cluster/py/cluster/client/genesis/convert_cluster"

    cd "${TOP}"
    #git status -s "${cc_dirs}" | awk -F ' ' '{print $2}' > "${SCRIPT_DIR}/changed_ccfiles.lst"
    git diff-tree --no-commit-id --name-only -r HEAD > "${SRC_CHANGED_FILES_LIST}"
    cd -
}

main() {
    create_ccfiles_list
}

main
set +ex
