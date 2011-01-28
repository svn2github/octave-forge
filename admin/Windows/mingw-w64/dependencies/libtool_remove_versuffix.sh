#!/usr/bin/sh

# remove the ${versuffix} from shared library names
echo "  Removing \${versuffix} from shared library names..."
cp -a $1 $1.ref
sed -e '/^soname_spec/ s+\\\${versuffix}++' $1 > $1.mod && cp -a $1.mod $1
touch -r $1.ref $1
rm -f $1.ref

