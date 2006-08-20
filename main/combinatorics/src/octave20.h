/*
## Copyright (C) 2006   Torsten Finke   <fi@igh-essen.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# $Revision$
# $Date$
# $RCSfile$
*/

/* this file is included to keep code compatible with older octave versions  */
/* see http://octave.sourceforge.net/new_developer.html                      */
/* actually it's partially copied from there                                 */

#ifdef USE_OCTAVE_NAN
#define lo_ieee_nan_value() octave_NaN
#define lo_ieee_inf_value() octave_Inf
#endif

