#!/bin/sh
# Author: lj1218

file_tmp="tmp_file.$$"
file_err="pull_img_error.$$"
file_img_tags_get_failed="img_tags_get_failed.txt"
repo_local="10.199.109.201:8082"
repo_public="registry.access.redhat.com"

function exec_cmd()
{
  local cmd=$1

  echo ${cmd}
  eval ${cmd}
}

function sync_docker_images()
{
  while read image pull_tag other_tags
  do
    echo "image:[${image}]   pull_tag:[${pull_tag}]   other_tags:[${other_tags}]"
  done <${file_tmp}

  echo
  echo "start@ $(date)"
  echo

  while read image pull_tag other_tags
  do
    img_url_pubic="${repo_public}/${image}:${pull_tag}"

    cmd="docker pull ${img_url_pubic}"
    exec_cmd "${cmd}"

    [ $? -ne 0 ] && {
      echo "Failed: ${cmd}" | tee -a ${file_err}
      continue
    }

    for tag in ${pull_tag} ${other_tags}
    do
        img_url_local="${repo_local}/${image}:${tag}"
        exec_cmd "docker rmi  ${img_url_local}"
        exec_cmd "docker tag  ${img_url_pubic} ${img_url_local}"
        exec_cmd "docker push ${img_url_local}"
    done
    echo
  done <${file_tmp}

  rm -f ${file_tmp}
  echo "Done@ $(date)"
}

rm -f ${file_img_tags_get_failed}
python get_openshift_latest_images.py ${file_tmp} ${file_img_tags_get_failed}
sync_docker_images
