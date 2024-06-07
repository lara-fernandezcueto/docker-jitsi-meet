#!/bin/bash

set -eu
SRCDIR=${1?No source directory given}
DESTDIR=${2?No destination directory given}
TMPDIR=${3:-${PWD}}

for ifile in $(find ${SRCDIR}/debian -name "*install") ; do
  subdir=${ifile##${SRCDIR}/debian}
  subdir=${subdir%%install}
  subdir=${subdir%%.}

  mkdir -p ${DESTDIR}/${subdir}
  while read orig dest ; do
    if [[ "${orig}" =~ ^#! ]] || [ -z "${orig}" ]; then
      continue
    fi
    mkdir -p "${DESTDIR}/${subdir}/${dest}"
    dir=$(dirname "${orig}")
    name=$(basename "${orig}")

    if [ -d ${TMPDIR}/${dir} ] ; then
      files=$(find ${SRCDIR}/${dir} ${TMPDIR}/${dir} -name "${name}")
    else
      files=$(find ${SRCDIR}/${dir} -name "${name}")
    fi
    if ! [ "${files}" ] ; then
      echo "${orig} not found in ${SRCDIR} ${TMPDIR}" >&2
      exit 1
    fi
    for f in ${files}; do
      cp -a $f ${DESTDIR}/${subdir}/${dest}
    done
  done < "${ifile}"
done
