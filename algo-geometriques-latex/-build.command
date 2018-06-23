#!/bin/sh
set -x
DIR=`dirname $0` &&
cd $DIR &&
rm -f algos-geometriques.pdf ref.* algos-geometriques.ilg algos-geometriques.ind &&
rm -f algos-geometriques.aux algos-geometriques.idx algos-geometriques.lof algos-geometriques.lot algos-geometriques.toc &&
rm -f algos-geometriques.log algos-geometriques.out algos-geometriques.synctex.gz &&
#--- First pass
PDF_LATEX=`which pdflatex` &&
MAKE_INDEX=`which makeindex` &&
$PDF_LATEX --file-line-error --shell-escape algos-geometriques.tex &&
touch ref.idx &&
touch ref.lof &&
touch ref.lot &&
touch ref.toc &&
iteration=0 &&
while [ `cmp -s ref.lof algos-geometriques.lof ; echo $?` -ne 0 ] \
   || [ `cmp -s ref.lot algos-geometriques.lot ; echo $?` -ne 0 ] \
   || [ `cmp -s ref.toc algos-geometriques.toc ; echo $?` -ne 0 ] \
   || [ `cmp -s ref.idx algos-geometriques.idx ; echo $?` -ne 0 ]
do
  cp algos-geometriques.idx ref.idx &&
  cp algos-geometriques.lof ref.lof &&
  cp algos-geometriques.lot ref.lot &&
  cp algos-geometriques.toc ref.toc &&
  $MAKE_INDEX -s $DIR/inclusions/style-indexes.ist algos-geometriques.idx &&
  $PDF_LATEX --file-line-error --shell-escape algos-geometriques.tex &&
  iteration=$((iteration+=1))
done &&
rm -f algos-geometriques.aux algos-geometriques.idx algos-geometriques.lof algos-geometriques.lot algos-geometriques.toc &&
rm -f algos-geometriques.log algos-geometriques.ilg algos-geometriques.ind algos-geometriques.out algos-geometriques.synctex.gz &&
rm -f ref.* temp.eb temp.eb.tex &&
echo "---------------- SUCCES $iteration iterations"
