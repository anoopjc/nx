#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

create_ccfiles_list() {
    local prev_pwd=$(pwd)
    local tmp_branch="tmp-ccfiles"
    local cur_branch

    # After creating a tmp branch, get the last files changes out of the repo.
    cd "${TOP}"
    cur_branch=$(git rev-parse --abbrev-ref HEAD)
    git branch -D ${tmp_branch} || echo "FAIL"; git checkout -b "${tmp_branch}"
    git reset HEAD~1

    # Create the ${SRC_CHANGED_FILES_LIST}
    rm -f "${SRC_CHANGED_FILES_LIST}"
    for i in "${SRC_CHANGED_FILES_BASE_DIRS[@]}"; do
        cd "${i}"
        #sub_cmd="cd {}; git status -s . | awk -F ' ' '{print \$2}' | sed -e 's#^#{}/#' | cut -c 3-;"
        # First sed "prefix" sub-dirs inside $SRC_CHANGED_FILES_LIST while
        # second sed "prefix" the entry from $SRC_CHANGED_FILES_BASE_DIRS.
        find . -maxdepth 1 \( -type l -o -type d \) -print0 | xargs -0 -n1 -I {} bash -c "cd {}; git status -s . | awk -F ' ' '{print \$2}' | sed -e 's#^#{}/#' | cut -c 3- | sed -e 's#^#${i}#'" >> ${SRC_CHANGED_FILES_LIST}
        cd - > /dev/null
    done

    # Clear the last commit changes from repo, goto org branch
    cd "${TOP}"
    git checkout -- .
    git checkout "${cur_branch}"

    cd "${prev_pwd}"
}

main() {
    create_ccfiles_list
}

main
set +ex
