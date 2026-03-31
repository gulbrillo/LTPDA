#!/bin/bash

if [ $# -lt 1 ]
then
        echo "usage: buildLaTeXTN <model_name>"
  exit
fi

input=`basename $1 .tex`
echo "compiling file: $input"

pdflatex $input.tex && pdflatex $input.tex && pdflatex $input.tex && open $input.pdf



