#!/bin/sh

csplit -f tmp_gsl $1 /DEFUN/ /GSL_FUNC_DOCSTRING/ /./ > /dev/null
cat tmp_gsl01 | sed "s/GSL_OCTAVE_NAME/$octave_name/g"
cat docstring.txt | sed 's/\\/\\\\/g' | sed 's/$/\\n\\/g' 
cat tmp_gsl03 | sed "s/GSL_OCTAVE_NAME/$octave_name/g" | sed "s/GSL_FUNC_NAME/$funcname/g" 

rm -f tmp_gsl* docstring.txt