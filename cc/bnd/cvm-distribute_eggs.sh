#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"
CC_BND_METHOD=${CC_BND_METHOD:-${METHOD_SAFE_BUT_SLOW}}

cvm-distribute_eggs_toall_cvms() {
    IP="$(_getip)"
    for i in $(svmips); do
        local ssh_cvm="${SSH_CVM_USER}@${i}"
        echo "$i"

        # create all needed dirs in the CVM
        local ssh_cmd
        ssh_cmd="mkdir -p $(dirname ${SSH_CVM_SERVER_EGG}) "
        ssh_cmd+="$(dirname ${SSH_CVM_CLIENT_EGG})"
        ssh "${ssh_cvm}" "${ssh_cmd}"
        if [ "${i}" = "${IP}" ]; then
            echo "CVM: [${i}] is the same machine!!!"
        fi
        # scp eggs; even in scp-ed CVM used during deployment of egg
        scp "${SSH_CVM_EXTRACTED_SERVER_EGG}" "${ssh_cvm}":"${SSH_CVM_SERVER_EGG}"
        scp "${SSH_CVM_EXTRACTED_CLIENT_EGG}" "${ssh_cvm}":"${SSH_CVM_CLIENT_EGG}"
    done
}

_replace_nx_eggs() {
    local ssh_cvm_server_egg=${1:-${SSH_CVM_SERVER_EGG}}
    local ssh_cvm_client_egg=${2:-${SSH_CVM_CLIENT_EGG}}
    for i in $(svmips); do
        local ssh_cvm="${SSH_CVM_USER}@${i}"
        echo "$i"

        local ssh_cmd
        # Preserve backup eggs, with date
        ssh_cmd="mkdir -p ${NX_BAK_DIR}; "
        ssh_cmd+="cp -af --backup=existing --suffix=\".$(date '+%Y-%m-%d_%H:%M:%S')\" "
        ssh_cmd+="-t \"${NX_BAK_DIR}\" \"${CVM_SERVER_EGG}\" \"${CVM_CLIENT_EGG}\""
        ssh "${ssh_cvm}" "${ssh_cmd}"

        # Replace eggs
        ssh_cmd="cp -af \"${ssh_cvm_server_egg}\" \"${CVM_SERVER_EGG}\"; "
        ssh_cmd+="cp -af \"${ssh_cvm_client_egg}\" \"${CVM_CLIENT_EGG}\";"
        ssh "${ssh_cvm}" "${ssh_cmd}"
    done

}

_restart_genesis() {
    allssh genesis restart
    # OR
    # cluster restart_genesis
}

create_updated_eggs() {
    local prev_pwd=$(pwd)
    local client_egg_filename=$(basename "${CVM_CLIENT_EGG}")
    local server_egg_filename=$(basename "${CVM_SERVER_EGG}")
    local client_egg_tmp_dir="${CVM_TMP_DIR_CLIENT_EGG_DIR}"
    local server_egg_tmp_dir="${CVM_TMP_DIR_SERVER_EGG_DIR}"

    # Remove both server & client eggs before making eggs
    cd "${server_egg_tmp_dir}"; /bin/rm -f "${server_egg_filename}"
    cd "${client_egg_tmp_dir}"; /bin/rm -f "${client_egg_filename}"
    # Create updated egg files
    cd "${server_egg_tmp_dir}"; jar -cvf "${server_egg_filename}" .
    cd "${client_egg_tmp_dir}"; jar -cvf "${client_egg_filename}" .
    # copy to the standard script's ssh-egg-dir
    cd "${server_egg_tmp_dir}"; mkdir -p "$(dirname ${SSH_CVM_EXTRACTED_SERVER_EGG})"; \
        cp -af "${server_egg_filename}" "${SSH_CVM_EXTRACTED_SERVER_EGG}"
    cd "${client_egg_tmp_dir}"; mkdir -p "$(dirname ${SSH_CVM_EXTRACTED_CLIENT_EGG})"; \
        cp -af "${client_egg_filename}" "${SSH_CVM_EXTRACTED_CLIENT_EGG}"

    cd "${prev_pwd}"
    # remove tmp dirs
    /bin/rm -rf "${client_egg_tmp_dir}" "${server_egg_tmp_dir}"
}

cvm-deploy_eggs_in_cvms() {
    _replace_nx_eggs
    _restart_genesis
}

main() {
    source_cvm_common
    if [ ${CC_BND_METHOD} = "${METHOD_UNSAFE_BUT_FAST}" ]; then
        create_updated_eggs
    fi
    cvm-distribute_eggs_toall_cvms
    cvm-deploy_eggs_in_cvms
}

main
set +ex
