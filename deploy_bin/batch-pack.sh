#!/usr/bin/env bash

base_path=/opt/workspace/cdcg_share
upload_path=${base_path}/data/upload
work_path=${base_path}/data/download/
log_file=${base_path}/logs/batch-pack.log

file_list_path=$1
target_file_path=$2
tar_file_name=$(basename ${target_file_path})
tar_file_path=$(dirname ${target_file_path})
tmp_path=${work_path}/tmp

[[ ! -f ${log_file} ]] && touch ${log_file}

function log() {
    local msg=$1
    echo "$(date '+%Y-%m-%d% %H:%M:%S') ${msg}" >>${log_file} 2>&1
}

function cp_files() {
    log "cp file start..."
    while read line
    do
        if [[ -n ${line} ]]; then
            filepath=$( echo ${line} | awk -F ' ' '{print $1}' )
            filename=$( echo ${line} | awk -F ' ' '{print $2}' )
            folder=$( echo ${line} | awk -F ' ' '{print $3}' )

            source_file="${upload_path}/${filepath}"
            target_folder="${tmp_path}/${folder}"
            target_file="${target_folder}/${filename}"

            [[ ! -d ${target_folder} ]] && mkdir -p ${target_folder}

            log "cp file: ${source_file} -> ${target_file}"
            cp -f ${source_file} ${target_file}
        fi
    done  < ${file_list_path}

    log "cp files success."
}

function zip_files() {
    log "package file start."
    cd ${tmp_path}
    zip -r ${tar_file_name} ./* >/dev/null 2>&1
    [[ ! -d ${tar_file_path} ]] && mkdir -p ${tar_file_path}
    mv ${tar_file_name} ${target_file_path}
    log "package file success."
}

function cleanup() {
    log "rm ${tmp_path}"
    cd ${work_path}
    [[ -d ${tmp_path} ]] && rm -rf ${tmp_path}
    log "rm ${tmp_path} success"
}

function main() {
    log "file list:${file_list_path}, target_file_path: ${target_file_path}"

    if [[ ! -d ${tmp_path} ]]
    then
        log "mkdir ${tmp_path} if not exist."
        mkdir -p ${tmp_path}
    fi
    cp_files
    zip_files
    cleanup
}

main
ret=$?

if [[  ret -eq 0 ]]; then
    log "zip files success."
    echo "${target_file_path}"
else
    log "zip files failed."
fi

