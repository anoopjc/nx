#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
GLOBALS="${SCRIPT_DIR}/globals.sh"

# VARS
## general
### bash vars
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
NORMAL=$(tput sgr0)
## script-files
CVM_COMMON_SCRIPT="${SCRIPT_DIR}/cvm-common.sh"
CVM_DISTRIBUTE_SCRIPT="${SCRIPT_DIR}/cvm-distribute_eggs.sh"
CVM_EXTRACT_NXEGGS_SCRIPT="${SCRIPT_DIR}/cvm-extract_nxeggs.sh"
UBVM_BUILD_SCRIPT="${SCRIPT_DIR}/ubvm-build_artifacts.sh"
UBVM_COMMON_SCRIPT="${SCRIPT_DIR}/ubvm-common.sh"
UBVM_DISTRIBUTE_SCRIPT="${SCRIPT_DIR}/ubvm-distribute_artifacts.sh"
SCRIPTS_README="${SCRIPT_DIR}/README.md"
### script directory inside the tar
BUILD_SCRIPTS_DIRNAME="cc-build_scripts"
### 2 methods to deploy updated script files
METHOD_SAFE_BUT_SLOW="safe_but_slow"
METHOD_UNSAFE_BUT_FAST="unsafe_but_fast"
## any node
### paths
GENERAL_TMP_DIR="\tmp"
### node-types
NODE_CVM="cvm"
NODE_UBVM="ubvm"
NODE_OTHER="other"
## ubvm
BASE_UBVM_DIR="/home/anoop.cyriac"
BASE_UBVM_BND_DIR="${BASE_UBVM_DIR}/_mac/ajc"
TOP="${BASE_UBVM_DIR}/_src/git/_pjt/_AOS/_gerrit/main"
TMP_DIR="${HOME}/tmp/ajc"
### src files
SRC_CHANGED_FILES_LIST="${SCRIPT_DIR}/changed_ccfiles.lst"
SRC_CHANGED_FILES_UNWANTED_PATH=".python/"
declare -a SRC_CHANGED_FILES_BASE_DIRS=(
    "${TOP}/infra_client/${SRC_CHANGED_FILES_UNWANTED_PATH}"
    "${TOP}/infra_server/${SRC_CHANGED_FILES_UNWANTED_PATH}"
)
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
BASE_CVM_BND_DIR="${BASE_CVM_DIR}/_mac/ajc"
SSH_CVM_DIR="${BASE_CVM_BND_DIR}"
CVM_TMP_DIR="${BASE_CVM_DIR}/tmp/ajc"        # create this
#### tar vars
SSH_CVM_TAR_DIR="${SSH_CVM_DIR}/tar"         # create this
SSH_CVM_TAR_BAK_DIR="${SSH_CVM_DIR}/tar.bak" # create this
SSH_CVM_INFRA_SERVER_TAR="${SSH_CVM_TAR_DIR}/$(basename ${INFRA_SERVER_TAR})"
SSH_CVM_INFRA_CLIENT_TAR="${SSH_CVM_TAR_DIR}/$(basename ${INFRA_CLIENT_TAR})"
#### egg vars
SSH_CVM_EGG_DIR="${SSH_CVM_TAR_DIR}/egg"
SSH_CVM_SERVER_EGG_DIR="${SSH_CVM_EGG_DIR}/server" # create this
SSH_CVM_CLIENT_EGG_DIR="${SSH_CVM_EGG_DIR}/client" # create this
##### created in the CVM where tar was copied and extracted
SSH_CVM_EXTRACTED_SERVER_EGG="${SSH_CVM_SERVER_EGG_DIR}/.python/nutanix_infra-server.egg"
SSH_CVM_EXTRACTED_CLIENT_EGG="${SSH_CVM_CLIENT_EGG_DIR}/.python/nutanix_infra-client.egg"
##### created in all CVMs copied from the scp-ed CVM
SSH_CVM_SERVER_EGG="${SSH_CVM_SERVER_EGG_DIR}/nutanix_infra-server.egg"
SSH_CVM_CLIENT_EGG="${SSH_CVM_CLIENT_EGG_DIR}/nutanix_infra-client.egg"
##### used when cc-scripts are copied directly
CVM_TMP_DIR_CLIENT_EGG_DIR="${CVM_TMP_DIR}/infra_client"
CVM_TMP_DIR_SERVER_EGG_DIR="${CVM_TMP_DIR}/infra_server"
#### scripts vars
SSH_CVM_SCRIPTS_DIR="${SSH_CVM_DIR}/scripts"
SSH_CVM_BUILD_SCRIPTS_TAR="${SSH_CVM_SCRIPTS_DIR}/${BUILD_SCRIPTS_DIRNAME}.tar.gz"
SSH_CVM_BUILD_SCRIPTS_DIR="${SSH_CVM_SCRIPTS_DIR}/${BUILD_SCRIPTS_DIRNAME}"
SSH_CVM_DISTRIBUTE_SCRIPT="${SSH_CVM_BUILD_SCRIPTS_DIR}/$(basename ${CVM_DISTRIBUTE_SCRIPT})"
SSH_CVM_EXTRACT_NXEGGS_SCRIPT="${SSH_CVM_BUILD_SCRIPTS_DIR}/$(basename ${CVM_EXTRACT_NXEGGS_SCRIPT})"
### NX vars
NX_BASE_DIR="/home/nutanix"
CVM_EGG_DIR="${NX_BASE_DIR}/cluster/lib/py"
CVM_SERVER_EGG="${CVM_EGG_DIR}/nutanix_infra-server.egg"
CVM_CLIENT_EGG="${CVM_EGG_DIR}/nutanix_infra-client.egg"
NX_BAK_DIR="${SSH_CVM_DIR}/nxbak" # create this
## Log
LOG_FILENAME="${BUILD_SCRIPTS_DIRNAME}.log"

# FUNCS
## general funcs
### path-manipulation funcs
#### return the passed path after removing redundant "/".
remove_redundant_fslash() {
    local path="${1}"
    shopt -s extglob
    echo ${path//\/*(\/)/\/}
}
#### return the path after removing the first root directory of the path.
remove_root_dir() {
    local path="${1}"
    echo ${path#*/}
}
### bnd specific
get_node_type() {
    local cvm_identifier="Nutanix Controller VM"
    local cvm_identifier_file="/etc/issue"
    local ubvm_identifier_file="/etc/ubvm-release"
    local node_type
    if grep -q "${cvm_identifier}" "${cvm_identifier_file}"; then
        node_type="${NODE_CVM}"
    elif [ -f "${ubvm_identifier_file}" ]; then
        node_type="${NODE_UBVM}"
    else
        node_type="${NODE_OTHER}"
    fi
    echo "${node_type}"
}
get_node_base_dir() {
    local node_type=$(get_node_type)
    if [ "${node_type}" = "${NODE_CVM}" ]; then
        base_dir="${BASE_CVM_BND_DIR}"
    elif [ "${node_type}" = "${NODE_UBVM}" ]; then
        base_dir="${BASE_UBVM_BND_DIR}"
    else
        base_dir="${GENERAL_TMP_DIR}"
    fi
    echo "${base_dir}"
}
### log functions
setup_logging() {
    local base_dir=$(get_node_base_dir)
    local log_dir="${base_dir}/logs"
    local log_file="${log_dir}/${LOG_FILENAME}"
    mkdir -p "${log_dir}"

    exec 3>&1 4>&2
    trap 'exec 2>&4 1>&3' 0 1 2 3
    exec &> >(tee -a "${log_file}")
}
### GIT functions
#### print git commit info
print_git_info() {
    local git_dir="${1}"
    local git_internal_dir

    cd "$(realpath ${git_dir})"
    git_internal_dir=$(git rev-parse --git-dir) 2>&1 || echo "FAIL"
    if [ x"${git_internal_dir:-x}" == xx ]; then
        printf "[%s] not a GIT directory" ${git_dir}
        cd -
        return
    fi

    git rev-parse HEAD | GREP_COLORS='ms=1;31' grep $(git rev-parse --short=0 HEAD)
    cd -
}
### timer/duration calculations. Ref: https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
### NOTE: timer funcs cannot be nested, but the "print_duration" can be used to
### print durations as needed.
#### To reset and start a timer, before printing any duration.
start_timer() {
    SECONDS_ORG=${SECONDS}
    SECONDS=0
    LAST_TIMER=0
    echo "${LIME_YELLOW}Timer Started: $(date)${NORMAL}"
}
#### to print duration in between after a start
print_duration() {
    local duration=$((${SECONDS} - ${LAST_TIMER}))
    local msg
    msg="Duration: $((${duration} / $((60 * 60))))h $(((${duration} / 60) % 60))m "
    msg+="$((${duration} % 60))s elapsed."
    printf "%s\n" "${LIME_YELLOW}$msg${NORMAL}"
    LAST_TIMER=${SECONDS}
}
#### to stop the currently running timer after printing last duration interval & total duration.
stop_timer() {
    print_duration

    local duration=${SECONDS}
    local msg
    msg="Total Duration: $((${duration} / $((60 * 60))))h "
    msg+="$(((${duration} / 60) % 60))m $((${duration} % 60))s elapsed."
    printf "%s\n" "${LIME_YELLOW}$msg${NORMAL}"
    LAST_TIMER=${SECONDS}
    SECONDS=$((${SECONDS_ORG} + ${SECONDS}))

    echo "${LIME_YELLOW}Timer stopped: $(date)${NORMAL}"
}
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
        rm -rf "${tarring_par_dir}"
        mkdir -p "${tarring_dir}"
        cp "${SCRIPTS_README}" "${GLOBALS}" "${UBVM_BUILD_SCRIPT}" \
            "${UBVM_DISTRIBUTE_SCRIPT}" "${CVM_DISTRIBUTE_SCRIPT}" \
            "${CVM_COMMON_SCRIPT}" "${UBVM_COMMON_SCRIPT}" \
            "${CVM_EXTRACT_NXEGGS_SCRIPT}" \
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
### source the ubvm common script file.
source_ubvm_common() {
    # shellcheck source="${SCRIPT_DIR}/ubvm-common.sh"
    source "${UBVM_COMMON_SCRIPT}"
}
## CVM
### source the cvm common script file.
source_cvm_common() {
    # shellcheck source="${SCRIPT_DIR}/cvm-common.sh"
    source "${CVM_COMMON_SCRIPT}"
}
