#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

SCRIPT_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"

# VARS
## script-files
CVM_DISTRIBUTE_SCRIPT="${SCRIPT_DIR}/cvm-distribute_eggs.sh"
CVM_HELPERS_SCRIPT="${SCRIPT_DIR}/cvm-helpers.sh"
UBVM_BUILD_SCRIPT="${SCRIPT_DIR}/ubvm-build_artifacts.sh"
UBVM_DISTRIBUTE_SCRIPT="${SCRIPT_DIR}/ubvm-distribute_artifacts.sh"
SCRIPTS_README="${SCRIPT_DIR}/README.md"
BUILD_SCRIPTS_DIRNAME="cc-build_scripts"
## ubvm
BASE_UBVM_DIR="/home/anoop.cyriac"
TOP="${BASE_UBVM_DIR}/_src/git/_pjt/_AOS/_gerrit/main"
TMP_DIR="${HOME}/tmp/ajc"
### tar vars
BUILD_CACHE_DIR="${BASE_UBVM_DIR}/.buildcache"
INFRA_SERVER_TAR_DIR="${BUILD_CACHE_DIR}/infra-server/local"
INFRA_CLIENT_TAR_DIR="${BUILD_CACHE_DIR}/infra-client/local"
INFRA_SERVER_TAR="${INFRA_SERVER_TAR_DIR}/infra-server-master-100-local-opt-clang-shlib.tar.gz"
INFRA_CLIENT_TAR="${INFRA_CLIENT_TAR_DIR}/infra-client-master-100-local-opt-clang-shlib.tar.gz"
## cvm
### ssh/scp vars
CVM_IP="10.46.17.207"
SSH_CVM_USER="nutanix"
SSH_CVM="${SSH_CVM_USER}@${CVM_IP}"
BASE_CVM_DIR="/home/nutanix"
SSH_CVM_DIR="${BASE_CVM_DIR}/_mac/ajc"
#### tar vars
SSH_CVM_TAR_DIR="${SSH_CVM_DIR}/tar"  # create this
SSH_CVM_TAR_BAK_DIR="${SSH_CVM_DIR}/tar.bak"  # create this
SSH_CVM_INFRA_SERVER_TAR="${SSH_CVM_TAR_DIR}/$( basename ${INFRA_SERVER_TAR} )"
SSH_CVM_INFRA_CLIENT_TAR="${SSH_CVM_TAR_DIR}/$( basename ${INFRA_CLIENT_TAR} )"
#### egg vars
SSH_CVM_EGG_DIR="${SSH_CVM_TAR_DIR}/egg"
SSH_CVM_SERVER_EGG_DIR="${SSH_CVM_EGG_DIR}/server"  # create this
SSH_CVM_CLIENT_EGG_DIR="${SSH_CVM_EGG_DIR}/client"  # create this
##### created in the CVM where tar was copied and extracted
SSH_CVM_EXTRACTED_SERVER_EGG="${SSH_CVM_SERVER_EGG_DIR}/.python/nutanix_infra-server.egg"
SSH_CVM_EXTRACTED_CLIENT_EGG="${SSH_CVM_CLIENT_EGG_DIR}/.python/nutanix_infra-client.egg"
##### created in all CVMs copied from the scp-ed CVM
SSH_CVM_SERVER_EGG="${SSH_CVM_SERVER_EGG_DIR}/nutanix_infra-server.egg"
SSH_CVM_CLIENT_EGG="${SSH_CVM_CLIENT_EGG_DIR}/nutanix_infra-client.egg"
#### scripts vars
SSH_CVM_SCRIPTS_DIR="${SSH_CVM_DIR}/scripts"
SSH_CVM_BUILD_SCRIPTS_TAR="${SSH_CVM_SCRIPTS_DIR}/${BUILD_SCRIPTS_DIRNAME}.tar.gz"
SSH_CVM_BUILD_SCRIPTS_DIR="${SSH_CVM_SCRIPTS_DIR}/${BUILD_SCRIPTS_DIRNAME}"
SSH_CVM_DISTRIBUTE_SCRIPT="${SSH_CVM_BUILD_SCRIPTS_DIR}/`basename ${CVM_DISTRIBUTE_SCRIPT}`"
### NX vars
NX_BASE_DIR="/home/nutanix"
CVM_EGG_DIR="${NX_BASE_DIR}/cluster/lib/py"
CVM_SERVER_EGG="${CVM_EGG_DIR}/nutanix_infra-server.egg"
CVM_CLIENT_EGG="${CVM_EGG_DIR}/nutanix_infra-client.egg"
NX_BAK_DIR="${SSH_CVM_DIR}/nxbak"  # create this

# FUNCS
## ubvm
### creates script-files' tar(${tar_file}) out of ${tarring_dir}(a copy of
### ${scripts_dir}), and if ${is_fresh} is true then clean the ${tarring_par_dir}
### and copy file to it.
create-cc_build_scripts-tar() {
    local tar_file=${1:-"${TMP_DIR}/${BUILD_SCRIPTS_DIRNAME}.tar.gz"}
    local scripts_dir=${2:-"${TMP_DIR}/${BUILD_SCRIPTS_DIRNAME}"}
    local tarring_par_dir="$(dirname ${scripts_dir})"
    local is_fresh=${3:-false}

    cd "${tarring_par_dir}"
    if [ ${is_fresh} = "true" ]; then
        rm -rf "${tarring_par_dir}"; mkdir -p "${tarring_dir}"
        cp "${SCRIPTS_README}" "${GLOBALS}" "${UBVM_BUILD_SCRIPT}" \
            "${UBVM_DISTRIBUTE_SCRIPT}" "${CVM_DISTRIBUTE_SCRIPT}" \
            "${CVM_HELPERS_SCRIPT}" \
            "${tarring_dir}/"
    fi
    local tarring_dir="${tarring_par_dir}/${BUILD_SCRIPTS_DIRNAME}"
    cp -af "${scripts_dir}" "${tarring_dir}"
    # Tar the dir ${tarring_dir} even after dereference/un-linking an links
    tar -C "$(dirname ${tarring_dir})" --dereference -czf "${tar_file}" \
        "$(basename ${tarring_dir})"
    rm -rf ${tarring_dir}
    cd -
}
### extract script files' dir into same directory containing ${tar_file}
extract-cc_build_scripts-tar() {
    local tar_file=${1:-"${TMP_DIR}/${BUILD_SCRIPTS_DIRNAME}.tar.gz"}
    local tar_file_dir="$(dirname ${tar_file})"

    cd "${TMP_DIR}"
    rm -rf "${BUILD_SCRIPTS_DIRNAME}"
    tar -C "${tar_file_dir}" -xzf "${tar_file}"
    cd -
}
