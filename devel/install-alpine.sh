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
    if [ "$(basename "${orig}")" = "*" ] ; then
      dir=$(dirname "${orig}")
      for f in $(find ${SRCDIR}/${dir} ${TMPDIR}/${dir} -type f) ; do
        cp -a $f ${DESTDIR}/${subdir}/${dest}
      done
    else
      f=$(find ${SRCDIR} ${TMPDIR} -path "*${orig}")
      if [ "${f}" ] ;then
        cp -a $f "${DESTDIR}/${subdir}/${dest}"
      else
        echo "${orig} not found in ${SRCDIR} ${TMPDIR}" >&2
        exit 1
      fi
    fi
  done < "${ifile}"
done
