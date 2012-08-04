## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Script File} {} test_devel
## Execute all available tests at once.
## The Octave control-devel package is based on the @uref{http://www.slicot.org, SLICOT} library.
## SLICOT needs a LAPACK library which is also a prerequisite for Octave itself.
## In case of failing test, it is highly recommended to use
## @uref{http://www.netlib.org/lapack/, Netlib's reference LAPACK}
## for building Octave.  Using ATLAS may lead to sign changes
## in some entries in the state-space matrices.
## In general, these sign changes are not 'wrong' and can be regarded as
## the result of state transformations.  Such state transformations
## (but not input/output transformations) have no influence on the
## input-output behaviour of the system.  For better numerics,
## the control package uses such transformations by default when
## calculating the frequency responses and a few other things.
## However, arguments like the Hankel singular Values (HSV) must not change.
## Differing HSVs and failing algorithms are known for using Framework Accelerate
## from Mac OS X 10.7.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

## identification
test @iddata/iddata
test @iddata/cat
test @iddata/detrend
test @iddata/fft

test moen4