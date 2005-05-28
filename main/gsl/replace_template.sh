#!/bin/sh

sed -e 's/\\/\\\\/g;s/$/\\n\\/g' < docstring.txt > docstring2.txt
sed -e "s/GSL_OCTAVE_NAME/$octave_name/g;s/GSL_FUNC_NAME/$funcname/g;/GSL_FUNC_DOCSTRING/r docstring2.txt" -e "/GSL_FUNC_DOCSTRING/d" $1
rm -f docstring.txt docstring2.txt
