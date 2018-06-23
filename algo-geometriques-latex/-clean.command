#!/bin/sh
set -x
DIR=`dirname $0` &&
cd $DIR &&
rm -f algos-geometriques.aux algos-geometriques.idx algos-geometriques.lof algos-geometriques.lot algos-geometriques.toc &&
rm -f algos-geometriques.log algos-geometriques.ilg algos-geometriques.ind algos-geometriques.out algos-geometriques.synctex.gz &&
rm -f ref.* temp.eb temp.eb.tex &&
echo "---------------- SUCCES $iteration iterations"
