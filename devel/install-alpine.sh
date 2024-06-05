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
    if [[ "${orig}" =~ ^#! ]] ; then
      continue
    fi
    mkdir -p "${DESTDIR}/${subdir}/${dest}"
    if [ -f "${SRCDIR}/${orig}" ] ; then
      cp -a ${SRCDIR}/${orig} "${DESTDIR}/${subdir}/${dest}"
    else
      cp -a ${TMPDIR}/${orig} "${DESTDIR}/${subdir}/${dest}"
    fi
  done < "${ifile}"
done
