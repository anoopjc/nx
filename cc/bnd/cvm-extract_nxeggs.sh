#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"
CC_BND_METHOD=${CC_BND_METHOD:-${METHOD_SAFE_BUT_SLOW}}

extract_nx_eggs() {
    local prev_pwd=$(pwd)
    local client_egg_filename=$(basename "${CVM_CLIENT_EGG}")
    local server_egg_filename=$(basename "${CVM_SERVER_EGG}")
    local client_egg_tmp_dir="${CVM_TMP_DIR_CLIENT_EGG_DIR}"
    local server_egg_tmp_dir="${CVM_TMP_DIR_SERVER_EGG_DIR}"

    mkdir -p "${client_egg_tmp_dir}" "${server_egg_tmp_dir}"

    # Copy current NX egg to TMP and extract both server & client
    cp "${CVM_SERVER_EGG}" "${server_egg_tmp_dir}/"
    cp "${CVM_CLIENT_EGG}" "${client_egg_tmp_dir}/"
    cd "${server_egg_tmp_dir}"; unzip "${server_egg_filename}"
    cd "${client_egg_tmp_dir}"; unzip "${client_egg_filename}"
    # Remove both server & client eggs before making eggs
    cd "${server_egg_tmp_dir}"; /bin/rm -f "${server_egg_filename}"
    cd "${client_egg_tmp_dir}"; /bin/rm -f "${client_egg_filename}"

    cd "${prev_pwd}"
}

main() {
    extract_nx_eggs
}

main
set +ex
