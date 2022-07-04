#!/bin/bash
# packs the current git HEAD (or any other supplied git head) into a tarball
# suitable for CRAN submission. Version comes from git as the latest tag.

N=scattermore
HEAD="${1:-HEAD}"
VERTAG=$(git describe --tags --no-abbrev "${HEAD}")
VER=${VERTAG#v}
ARCHIVE=${N}_${VER}.tar.gz

TMPDIR=".tmpbuild-$$"

mkdir ${TMPDIR} || exit 1

git archive --format=tar --prefix="${N}/" "${HEAD}" \
| tar f - \
	--delete "${N}/pack_cran.sh" \
	--delete "${N}/code_format.sh" \
	--delete "${N}/media" \
	--delete "${N}/README.md" \
| tar xf - -C ${TMPDIR}

R --vanilla CMD build ./${TMPDIR}/${N}/ --compact-vignettes

rm -fr ${TMPDIR}

R --vanilla CMD check --as-cran ${ARCHIVE}
#R CMD check --as-cran --use-valgrind ${ARCHIVE}

echo "Did you run roxygen? (and valgrind?)"
