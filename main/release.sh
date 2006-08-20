#!/bin/bash

## List of packages to release
packages="audio combinatorics comm control econometrics fixed general geometry gsl ident image io irsa linear-algebra miscellaneous octcdf optim parallel plot signal specfun special-matrix splines statistics strings struct symbolic time vrml"

## The current date to append to .tar.gz filenames
## XXX: It would be better to use the version numbers from DESCRIPTION
##      files when creating seperate packages and the date when creating
##      the bundle.
d=`date --rfc-3339=date`

## For each package:
for p in $packages; do
    ## Check if src/autogen.sh exist and (possibly) execute it
    if [ -f $p/src/autogen.sh ]; then
        cd $p/src
        sh ./autogen.sh
        cd ../..
    fi
    ## Create the tar-ball
    tar -zcf $p-$d.tar.gz $p
done

## Create bundle
tar -zcf octave-forge-main-$d.tar.gz $packages
