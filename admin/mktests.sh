#! /bin/sh

# Create a new fntests.m file
echo "fid=fopen('fntests.log','w');" > fntests.m
echo "if fid<0,error('could not open fntests.log for writing');end" >>fntests.m
echo "test('','explain',fid);" >> fntests.m
echo "passes=0; tests=0;" >>fntests.m

# Find all non-cvs directories
DIRS=`find . -type d ! -name CVS`

# Find the tests in that directory
for dir in $DIRS; do
    dir=${dir#./}

    # skip the NOINSTALL directories
    if test -f "$dir/NOINSTALL"; then continue; fi

    # Build a list of possible test files
    FILES=""

    # Find all successfully compiled .cc files
    cxx_files=`echo $dir/*.cc`
    if test "$cxx_files" != "$dir/*.cc"; then 
	for file in $cxx_files; do
	    if test -f ${file%.cc}.o; then FILES="$FILES $file"; fi
	done
    fi

    # Find all m-files
    m_files=`echo $dir/*.m`
    if test "$m_files" != "$dir/*.m"; then FILES="$FILES $m_files"; fi

    # No C++ of m-files, so no testing
    if test -z "$FILES" ; then continue; fi

    # Find all files with %!test or %!assert in them
    # XXX FIXME XXX is there a system independent way of doing (test|assert)
    TESTS=`grep -l -E '^%![ta][es]s' $FILES`

    # if no files have tests in them, skip
    if test -z "$TESTS" ; then
	echo "printf('%-40s --- no tests','$dir');disp('');" >>fntests.m
    else 
	echo "dp=dn=0;" >>fntests.m
	for file in $TESTS ; do
            echo "[p,n] = test('$file','quiet',fid);" >>fntests.m
            echo "dp += p; dn += n;" >>fntests.m
	done
	echo "printf('%-40s --- ','$dir');" >>fntests.m
	echo "if dp==dn, printf('success'); else" >>fntests.m
        echo "printf('passes %d out of %d tests',dp,dn); end" >>fntests.m
        echo "disp(''); passes += dp; tests += dn;" >>fntests.m
    fi

done

echo "printf('passes %d out of %d tests',passes,tests);disp('');" >> fntests.m
echo "printf('see fntests.log for details');disp('');" >> fntests.m
echo "fclose(fid);" >> fntests.m
