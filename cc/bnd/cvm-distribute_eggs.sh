#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

get_cvm_helpers() {
    source "${CVM_HELPERS_SCRIPT}"
}

cvm-distribute_eggs_toall_cvms() {
    IP="$(_getip)"
    for i in $(svmips); do
        local ssh_cvm="${SSH_CVM_USER}@${i}"
        echo "$i"

        # create all needed dirs in the CVM
        local ssh_cmd
        ssh_cmd="mkdir -p ${NX_BAK_DIR} ${SSH_CVM_SERVER_EGG_DIR} "
        ssh_cmd+="${SSH_CVM_CLIENT_EGG_DIR}"
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
    for i in $(svmips); do
        local ssh_cvm="${SSH_CVM_USER}@${i}"
        echo "$i"

        local ssh_cmd
        # Preserve backup eggs, with date
        ssh_cmd="cp --backup=existing --suffix=\".$(date '+%Y-%m-%d_%H:%M:%S')\" "
        ssh_cmd+="-t ${NX_BAK_DIR} ${CVM_SERVER_EGG} ${CVM_CLIENT_EGG}"
        ssh "${ssh_cvm}" "${ssh_cmd}"

        # Replace eggs
        ssh_cmd="cp ${SSH_CVM_SERVER_EGG} ${CVM_SERVER_EGG}; "
        ssh_cmd+="cp ${SSH_CVM_CLIENT_EGG} ${CVM_CLIENT_EGG};"
        ssh "${ssh_cvm}" "${ssh_cmd}"
    done

}

_restart_genesis(){
        allssh genesis restart
        # OR
        # cluster restart_genesis
}

cvm-deploy_eggs_in_cvms() {
    _replace_nx_eggs
    _restart_genesis
}

main() {
    get_cvm_helpers
    cvm-distribute_eggs_toall_cvms
    cvm-deploy_eggs_in_cvms
}

main
set +ex
