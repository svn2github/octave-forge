/*

Copyright (C) 2001-2003 Motorola Inc
Copyright (C) 2001-2003 Laurent Mazet
Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (__int_fixed_cc)
#define __int_fixed_cc 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma implementation
#endif

#include <iostream>
#include <cmath>

#include "fixed.h"

#if !defined(OCTAVE_FORGE)

#if defined(__APPLE__) && defined(__MACH__) 
extern "C" int isnan (double); 
extern "C" int isinf (double); 
#endif 

#define lo_ieee_isnan(x) isnan(x)
#define lo_ieee_isinf(x) isinf(x)

#else
#include <octave/lo-ieee.h>
#endif

// Various tables of power 5.
#if (SIZEOF_FIXED == 2)
char pow5[16][16] = {
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,1,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,9,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,4,8,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,2,4,4,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,1,2,2,0,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,6,1,0,3,5,1,5,6,2,5 },
  { 0,0,0,0,0,3,0,5,1,7,5,7,8,1,2,5 } };
#elif (SIZEOF_FIXED == 4)
char pow5[32][32] = {
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,8,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,4,4,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,0,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,1,0,3,5,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,5,1,7,5,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,5,2,5,8,7,8,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,6,2,9,3,9,4,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,8,1,4,6,9,7,2,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,9,0,7,3,4,8,6,3,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,5,3,6,7,4,3,1,6,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,7,6,8,3,7,1,5,8,2,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,8,4,1,8,5,7,9,1,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,9,2,0,9,2,8,9,5,5,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,9,6,0,4,6,4,4,7,7,5,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,9,8,0,2,3,2,2,3,8,7,6,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,9,0,1,1,6,1,1,9,3,8,4,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,7,4,5,0,5,8,0,5,9,6,9,2,3,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,3,7,2,5,2,9,0,2,9,8,4,6,1,9,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,1,8,6,2,6,4,5,1,4,9,2,3,0,9,5,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,9,3,1,3,2,2,5,7,4,6,1,5,4,7,8,5,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,4,6,5,6,6,1,2,8,7,3,0,7,7,3,9,2,5,7,8,1,2,5 } };
#elif (SIZEOF_FIXED == 8)
char pow5[64][64] = {
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,8,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,4,4,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,0,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,1,0,3,5,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,5,1,7,5,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,5,2,5,8,7,8,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,6,2,9,3,9,4,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,8,1,4,6,9,7,2,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,9,0,7,3,4,8,6,3,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,5,3,6,7,4,3,1,6,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,7,6,8,3,7,1,5,8,2,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,8,4,1,8,5,7,9,1,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,9,2,0,9,2,8,9,5,5,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,9,6,0,4,6,4,4,7,7,5,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,9,8,0,2,3,2,2,3,8,7,6,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,9,0,1,1,6,1,1,9,3,8,4,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,4,5,0,5,8,0,5,9,6,9,2,3,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,7,2,5,2,9,0,2,9,8,4,6,1,9,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,6,2,6,4,5,1,4,9,2,3,0,9,5,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,3,1,3,2,2,5,7,4,6,1,5,4,7,8,5,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,5,6,6,1,2,8,7,3,0,7,7,3,9,2,5,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,2,8,3,0,6,4,3,6,5,3,8,6,9,6,2,8,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,6,4,1,5,3,2,1,8,2,6,9,3,4,8,1,4,4,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,8,2,0,7,6,6,0,9,1,3,4,6,7,4,0,7,2,2,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,9,1,0,3,8,3,0,4,5,6,7,3,3,7,0,3,6,1,3,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,5,5,1,9,1,5,2,2,8,3,6,6,8,5,1,8,0,6,6,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,2,7,5,9,5,7,6,1,4,1,8,3,4,2,5,9,0,3,3,2,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,6,3,7,9,7,8,8,0,7,0,9,1,7,1,2,9,5,1,6,6,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,1,8,9,8,9,4,0,3,5,4,5,8,5,6,4,7,5,8,3,0,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,9,4,9,4,7,0,1,7,7,2,9,2,8,2,3,7,9,1,5,0,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,5,4,7,4,7,3,5,0,8,8,6,4,6,4,1,1,8,9,5,7,5,1,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,7,3,7,3,6,7,5,4,4,3,2,3,2,0,5,9,4,7,8,7,5,9,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,6,8,6,8,3,7,7,2,1,6,1,6,0,2,9,7,3,9,3,7,9,8,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,6,8,4,3,4,1,8,8,6,0,8,0,8,0,1,4,8,6,9,6,8,9,9,4,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,8,4,2,1,7,0,9,4,3,0,4,0,4,0,0,7,4,3,4,8,4,4,9,7,0,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,2,1,0,8,5,4,7,1,5,2,0,2,0,0,3,7,1,7,4,2,2,4,8,5,3,5,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,1,0,5,4,2,7,3,5,7,6,0,1,0,0,1,8,5,8,7,1,1,2,4,2,6,7,5,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,5,5,2,7,1,3,6,7,8,8,0,0,5,0,0,9,2,9,3,5,5,6,2,1,3,3,7,8,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,7,7,6,3,5,6,8,3,9,4,0,0,2,5,0,4,6,4,6,7,7,8,1,0,6,6,8,9,4,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,1,7,8,4,1,9,7,0,0,1,2,5,2,3,2,3,3,8,9,0,5,3,3,4,4,7,2,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,0,8,9,2,0,9,8,5,0,0,6,2,6,1,6,1,6,9,4,5,2,6,6,7,2,3,6,3,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,4,4,6,0,4,9,2,5,0,3,1,3,0,8,0,8,4,7,2,6,3,3,3,6,1,8,1,6,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,2,2,3,0,2,4,6,2,5,1,5,6,5,4,0,4,2,3,6,3,1,6,6,8,0,9,0,8,2,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,1,1,1,5,1,2,3,1,2,5,7,8,2,7,0,2,1,1,8,1,5,8,3,4,0,4,5,4,1,0,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,7,7,5,5,5,7,5,6,1,5,6,2,8,9,1,3,5,1,0,5,9,0,7,9,1,7,0,2,2,7,0,5,0,7,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,3,8,7,7,7,8,7,8,0,7,8,1,4,4,5,6,7,5,5,2,9,5,3,9,5,8,5,1,1,3,5,2,5,3,9,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,9,3,8,8,9,3,9,0,3,9,0,7,2,2,8,3,7,7,6,4,7,6,9,7,9,2,5,5,6,7,6,2,6,9,5,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,4,6,9,4,4,6,9,5,1,9,5,3,6,1,4,1,8,8,8,2,3,8,4,8,9,6,2,7,8,3,8,1,3,4,7,6,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,7,3,4,7,2,3,4,7,5,9,7,6,8,0,7,0,9,4,4,1,1,9,2,4,4,8,1,3,9,1,9,0,6,7,3,8,2,8,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6,7,3,6,1,7,3,7,9,8,8,4,0,3,5,4,7,2,0,5,9,6,2,2,4,0,6,9,5,9,5,3,3,6,9,1,4,0,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,3,3,6,8,0,8,6,8,9,9,4,2,0,1,7,7,3,6,0,2,9,8,1,1,2,0,3,4,7,9,7,6,6,8,4,5,7,0,3,1,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,6,8,4,0,4,3,4,4,9,7,1,0,0,8,8,6,8,0,1,4,9,0,5,6,0,1,7,3,9,8,8,3,4,2,2,8,5,1,5,6,2,5 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,8,4,2,0,2,1,7,2,4,8,5,5,0,4,4,3,4,0,0,7,4,5,2,8,0,0,8,6,9,9,4,1,7,1,1,4,2,5,7,8,1,2,5 } };
#else
#  error ("Tables of power 5 only availble for fp_uint sizes of 4 and 8 bytes");
#endif

const fp_uint one = 1;

#if !defined(OCTAVE_FORGE)
void Fixed::_error (char *file, int line, Fixed::Code code) {

  std::cerr << "Error in file " << file 
            << " at line " << line << std::endl;
  std::cerr << message[code] << std::endl;

  exit (1);

}

void Fixed::_warning (char *file, int line, Fixed::Code code) {

  std::cerr << "Warning in file " << file
            << " at line " << line << std::endl;
  std::cerr << message[code] << std::endl;
}
#endif

/* FixedPoint de-structuror */

double FixedPoint::fixedpoint() const {

  double v = (signbit()) ? -(double)((-number)&filter) : (double)number;
  
  v /= (1<<decsize);
  
  return (v);
}

/* FixedPoint constructors */

FixedPoint::FixedPoint (unsigned int is, unsigned int ds, const fp_uint n) {

  /* This constructor helps to construct FixedPoint from the `number'
     field of an FixedPoing object. As the sign bit is not marked,
     this constructor can overflow. */

  /* Check sizes */
  if (ds+is > maxfixedsize)
    {
      fixed_error (Fixed::WRONGFIXSIZE);
      return;
    }
  
  /* Get sizes */
  decsize = ds;
  intsize = is;

  /* Get filters */
  filter = (one << (is+ds+1)) - 1;

  /* Build number */
  number = n&filter;

  /* Check for overflow */
  if ((Fixed::FP_Overflow) && (n > filter))
    fixed_warning (Fixed::LOSS_MSB_INT);
  
  /* Debug */  
  if (Fixed::FP_Debug)
    value = fixedpoint();
}

FixedPoint::FixedPoint (unsigned int is, unsigned int ds,
                        const fp_uint i, const fp_uint d) {

  /* This constructor helps to construct FixedPoint from an (i,d)
     representation. As the sign bit is not marked, this constructor
     can overflow from integer part and decimal part. */

  /* Check sizes */
  if (ds+is > maxfixedsize)
    {
      fixed_error (Fixed::WRONGFIXSIZE);
      return;
    }
  
  /* Get sizes */
  decsize = ds;
  intsize = is;

  /* Get filters */
  filter = (one << (is+ds+1)) - 1;
  fp_uint filter_int = (one << (is+1)) - 1;
  fp_uint filter_dec = (one << ds) - 1;

  /* Build number */
  number = ((i&filter_int) << ds) | (d&filter_dec);

  /* Check for overflow */
  if (Fixed::FP_Overflow) {
    if (d > filter_dec)
      fixed_warning (Fixed::LOSS_MSB_DEC);
    if (i > filter_int)
      fixed_warning (Fixed::LOSS_MSB_INT);
  }
  
  /* Debug */  
  if (Fixed::FP_Debug)
    value = fixedpoint();
}

FixedPoint::FixedPoint (unsigned int is, unsigned int ds,
                        const FixedPoint &x) {
  
  /* This constructor helps to construct FixedPoint from a other
     FixedPoint object. Even if this constructor loss some bits from
     integer part, the sign bit is kept. */

  /* Check sizes */
  if (ds+is> maxfixedsize)
    {
      fixed_error (Fixed::WRONGFIXSIZE);
      return;
    }
      
  /* Get sizes */
  decsize = ds;
  intsize = is;

  /* Get sign bit */
  fp_uint s = x.signbit();
  
  /* Get filter */
  filter = (one << (is+ds+1)) - 1;

  /* Create decimal part */
  int diffds = ds-x.decsize;
  fp_uint d = x.number & ((one << x.decsize)-1);
  d = (diffds > 0) ? ( d << diffds) : (d >> (-diffds));

  /* Create integer part */
  int diffis = is-x.intsize;
  fp_uint i = (x.number >> x.decsize) & ((one << x.intsize)-1);
  if ((s) && (diffis > 0))
    i |= ((one << diffis)-1) << x.intsize;
  i &= (one << is)-1;
  i |= (s << is);

  /* Create number */
  number = (i << ds) | d;

  /* Check for overflow */
  if (Fixed::FP_Overflow) {
    if (s) {
      if ((diffis < 0) &&
	  ((x.number >> x.decsize) < ((one << (1-diffis))-1) << is))
	fixed_warning(Fixed::LOSS_MSB_FP);
    }
    else {
      if ((x.number >> x.decsize) >= (one << is))
	fixed_warning(Fixed::LOSS_MSB_FP);
    }
  }

  /* Debug */  
  if (Fixed::FP_Debug)
    value = fixedpoint();
}

FixedPoint::FixedPoint (unsigned int is, unsigned int ds, double x) {
  
  /* This constructor helps to construct FixedPoint from a double
     precision number. This constructor act as a ADC and clip too
     large value*/
  
  /* Check sizes */
  if (ds+is > maxfixedsize)
    fixed_error (Fixed::WRONGFIXSIZE);

  /* Get sizes */
  decsize = ds;
  intsize = is;
  
  /* Get filter */
  filter = (one << (is+ds+1)) - 1;

  /* Create clipping values */
  double negclip = - double(one<<is);
  double posclip = double(one<<is) - 1./(one<<ds);

  /* Check for erreur */
  if (lo_ieee_isnan(x)) {
    /* Not a number */

    x = 0;
    if (Fixed::FP_Overflow)
      fixed_warning(Fixed::NAN_CONST);
    
  } else if (lo_ieee_isinf(x)) {
    /* Infinity */
    
    x = (lo_ieee_isinf(x) > 0) ? posclip : negclip;
    if (Fixed::FP_Overflow)
      fixed_warning(Fixed::INF_CONST);

  } else if (x > posclip) {
    /* Positive clipping */

    x = posclip;
    if (Fixed::FP_Overflow)
      fixed_warning(Fixed::LOSS_MSB_DB);

  }

  else if (x < negclip) {
    /* Negative clipping */

    x = negclip;
    if (Fixed::FP_Overflow)
      fixed_warning(Fixed::LOSS_MSB_DB);
  }
  
  /* Create number */
  if (x == negclip)
    number = one<<(is+ds);
  else {
    number = (fp_uint) floor(x*(1<<ds));
  }
  number &= filter;
  
  /* Debug */  
  if (Fixed::FP_Debug)
    value = fixedpoint();
}

FixedPoint::FixedPoint (const fp_int x) {
  
  /* This constructor helps to construct FixedPoint from a
     integer. This constructor act as a ADC and clip too large
     value. */

  
  fp_int x_clipped;

  /* Create clipping values */
  fp_int negclip = - fp_int(one<<maxfixedsize);
  fp_int posclip = fp_int(one<<maxfixedsize) - 1;

  /* Check for erreur */
  if (x > posclip) {
    /* Positive clipping */

    x_clipped = posclip;
    if (Fixed::FP_Overflow)
      fixed_warning(Fixed::LOSS_MSB_DB);
    
  }
  else if (x < negclip) {
    /* Negative clipping */

    x_clipped = negclip;
    if (Fixed::FP_Overflow)
      fixed_warning(Fixed::LOSS_MSB_DB);
  }
  else
    x_clipped = x;
  
  /* Get sizes */
  decsize = 0;
  intsize = 0;
  fp_int tmp = x_clipped;
  while ((tmp) && (~tmp)) {
    intsize++;
    tmp>>=1;
   }

  /* Get filter */
  filter = (one << (intsize+1)) - 1;

  /* Create number */
  number = x_clipped & filter;
  
  /* Debug */  
  if (Fixed::FP_Debug)
    value = fixedpoint();
}

/* This is a stupid constructor, that drops the decimal part, but it
   at least allows the C++ complex class to do log10 */
FixedPoint::FixedPoint (const double y) {
  *this = FixedPoint(fp_int(y));
}

/* FixedPoint intern operators */
FixedPoint &FixedPoint::operator = (const fp_int &x) {
  FixedPoint y(x);
  
  intsize = y.intsize;
  decsize = y.decsize;
  filter = y.filter;
  number = y.number;
  if (Fixed::FP_Debug)
    value = y.value;
  
  return (*this);
}

FixedPoint &FixedPoint::operator = (const FixedPoint &x) {
  
  intsize = x.intsize;
  decsize = x.decsize;
  filter = x.filter;
  number = x.number;
  if (Fixed::FP_Debug)
    value = x.value;
  
  return (*this);
}

FixedPoint &FixedPoint::operator += (const FixedPoint &x) {
  FixedPoint n;
  
  if ((x.intsize != intsize) || (x.decsize != decsize)) {
    int _intsize = (x.intsize > intsize) ? x.intsize : intsize;
    int _decsize = (x.decsize > decsize) ? x.decsize : decsize;
    *this = FixedPoint(_intsize, _decsize, *this);
    n = FixedPoint(_intsize, _decsize, x);
  }
  else
    n = x;
  
  char s = Fixed::FP_Overflow ? signbit() : 0;
  
  number += n.number;
  if ((Fixed::FP_Overflow) && (s == n.signbit()) &&
      ((s?((~number)&filter):number)>>(intsize+decsize)))
    fixed_warning(Fixed::LOSS_MSB_ADD);
  
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_add++;
  
  return (*this);
}

FixedPoint &FixedPoint::operator -= (const FixedPoint &x) {
  FixedPoint n;
  
  if ((x.intsize != intsize) || (x.decsize != decsize)) {
    int _intsize = (x.intsize > intsize) ? x.intsize : intsize;
    int _decsize = (x.decsize > decsize) ? x.decsize : decsize;
    *this = FixedPoint(_intsize, _decsize, *this);
    n = FixedPoint(_intsize, _decsize, x);
  }
  else
    n = x;
  
  char s = Fixed::FP_Overflow ? signbit() : 0;
  
  number -= n.number;
  if ((Fixed::FP_Overflow) && (s != n.signbit()) &&
      ((s?((~number)&filter):number)>>(intsize+decsize)))
    fixed_warning(Fixed::LOSS_MSB_SUB);
  
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_sub++;
  
  return (*this);
}

FixedPoint &FixedPoint::operator *= (const FixedPoint &x) {

  /* To avoid any problem of multiplication overflow, we limit
     the maximum number space to maxfixedsize */

  FixedPoint n;

  if ((x.intsize != intsize) || (x.decsize != decsize)) {
    int _intsize = (x.intsize > intsize) ? x.intsize : intsize;
    int _decsize = (x.decsize > decsize) ? x.decsize : decsize;
    *this = FixedPoint(_intsize, _decsize, *this);
    n = FixedPoint(_intsize, _decsize, x);
  }
  else
    n = x;

  fp_uint n1 = (signbit()) ? (-number)&filter : number;
  fp_uint n2 = (n.signbit()) ? (-n.number)&filter : n.number;

  if (intsize+decsize < halffixedsize) {

    /*
      No overflow problem.
    */

    n1 *= n2;
    n1 >>= decsize;

    if ((Fixed::FP_Overflow) &&
        (!((signbit() != n.signbit()) &&
           (fp_int(n1) == (1L<<(intsize+decsize))))) &&
        (n1>>(intsize+decsize)))
      fixed_warning(Fixed::LOSS_MSB_MULT);

    number = ((signbit() != n.signbit()) ? -n1 : n1)&filter;

  }
  else {

    /*
      Overflow problem.
     */

    int size = intsize+decsize;
    int unconsistent_bits = size - halffixedsize + 1;
    fp_int lsb_filter = (1<<unconsistent_bits)-1;

    /*
      Split n1 and n2 into two part.
     */

    fp_uint n1_high = n1>>unconsistent_bits;
    fp_uint n1_low = n1&lsb_filter;
    fp_uint n2_high = n2>>unconsistent_bits;
    fp_uint n2_low = n2&lsb_filter;

    /*
      Calculate the lowest part of n1*n2.
     */

    fp_uint n_low = n1_low*n2_low;

    /*
      Calculate the medium part of n1*n2 and extract
      the msb part of the lowest part to avoid bit
      redundancy.
    */

    fp_uint n_medium = n1_high*n2_low + n1_low*n2_high +
      (n_low>>unconsistent_bits);
    n_low &= lsb_filter;

    /*
      Calculate the highest part of n1*n2 and extract
      the msb part of the medium part to avoid bit
      redundancy.
    */
    
    fp_uint n_high = n1_high*n2_high + (n_medium>>unconsistent_bits);
    n_medium &= lsb_filter;

    /*
      Keep only bits in fixed point format from the
      lowest part of the product.
    */

    fp_uint n_sized = n_low >> decsize;
  
    /*
      Keep only bits in fixed point format from the
      medium part of the product and put them at right
      position.
    */

    if (int(decsize) > unconsistent_bits)
      n_sized += n_medium>>(decsize-unconsistent_bits);
    else
      n_sized += n_medium<<(unconsistent_bits-decsize);

    /*
      Keep only bits in fixed point format from the
      highest part of the product and put them at right
      position 
    */

    if (int(decsize) > 2*unconsistent_bits)
      n_sized += n_high >>(decsize-2*unconsistent_bits);
    else
      n_sized += n_high <<(2*unconsistent_bits-decsize);

    /*
      Check format and sign bit.
    */

    if (Fixed::FP_Overflow) {
      int _t = 2*unconsistent_bits-decsize;
      if ((!((signbit() != n.signbit()) &&
             (fp_int(n_sized) == (1L<<(intsize+decsize))))) && 
	  (((_t >= 0) && (((n_high<<_t)>>_t) != n_high)) ||
	   (n_sized>>(intsize+decsize))))
        fixed_warning(Fixed::LOSS_MSB_MULT);
    }
    
    number = ((signbit() != n.signbit()) ? -n_sized : n_sized)&filter;

  }

  if (Fixed::FP_Debug)
    value = fixedpoint();

  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_mult++;

  return (*this);
}

FixedPoint &FixedPoint::operator /= (const FixedPoint &x) {

  /* This operator need to really be implemented in a fixed precision
     manner */
  
  double y1 = fixedpoint();
  double y2 = x.fixedpoint();
  *this = FixedPoint((x.intsize > intsize) ? x.intsize : intsize,
                     (x.decsize > decsize) ? x.decsize : decsize,
                     y1/y2);

  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_div++;
  
  return (*this);
}

FixedPoint &FixedPoint::operator <<= (const int s) {
  
  if ((Fixed::FP_Overflow) &&
      (((intsize+decsize-s>0) &&(number)) ||
       (((signbit()?((~number)&filter):number)>>(intsize+decsize-s)))))
    fixed_warning(Fixed::LOSS_MSB_LSHIFT);
  
  number <<= s;    
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_lshift++;
  
  return (*this);
}

FixedPoint &FixedPoint::operator >>= (const int s) {

  char sign = signbit();
  
  number >>= s;
  
  if (sign)
    number |= (filter >> s) ^ filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_rshift++;
  
  return (*this);
}

/* FixedPoint unary operators */

FixedPoint &FixedPoint::operator ++ () {
  // prefix ++
    
  char s = Fixed::FP_Overflow ? signbit() : 0;
  
  number++;
  if ((Fixed::FP_Overflow) && (!s) && (signbit()))
    fixed_warning(Fixed::LOSS_MSB_PRE_INC);
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_inc++;
  
  return(*this);
}

FixedPoint &FixedPoint::operator -- () {
  // prefix --
 
  char s = Fixed::FP_Overflow ? signbit() : 0;
  
  number--;
  if ((Fixed::FP_Overflow) && (s) && (!signbit()))
    fixed_warning(Fixed::LOSS_MSB_PRE_DEC);
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_dec++;
  
  return(*this);
}

FixedPoint FixedPoint::operator ++ (int) {
  // postfix ++

  FixedPoint n(*this);
  
  char s = Fixed::FP_Overflow ? signbit() : 0;
  
  number++;
  if ((Fixed::FP_Overflow) && (!s) && (signbit()))
    fixed_warning(Fixed::LOSS_MSB_POST_INC);
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_inc++;
  
  return (n);
}

FixedPoint FixedPoint::operator -- (int) {
  // postfix --

  FixedPoint n(*this);
  
  char s = Fixed::FP_Overflow ? signbit() : 0;
  
  number--;
  if ((Fixed::FP_Overflow) && (s) && (!signbit()))
    fixed_warning(Fixed::LOSS_MSB_PRE_DEC);
  number &= filter;
  
  if (Fixed::FP_Debug)
    value = fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_dec++;
  
  return (n);
}

FixedPoint operator - (const FixedPoint &x) {
  
  FixedPoint n(x);
  
  n.number = (-n.number) & n.filter;
  
  if (Fixed::FP_Debug)
    n.value = n.fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_neg++;
  
  return (n);
}

FixedPoint operator ! (const FixedPoint &x) {

  FixedPoint n(x);
  
  n.number = n.number & (n.filter >> 1);
  
  if (Fixed::FP_Debug)
    n.value = n.fixedpoint();
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_comp++;
  
  return (n);
}

/* FixedPoint comparators */

bool operator ==  (const FixedPoint &x, const FixedPoint &y) {
  
  if ((x.decsize == y.decsize) && (x.intsize == y.intsize))
    return (x.number == y.number);
  
  unsigned int dsmax = (x.decsize > y.decsize) ? x.decsize : y.decsize;
  unsigned int ismax = (x.intsize > y.intsize) ? x.intsize : y.intsize;
  
  FixedPoint x1(ismax, dsmax, x);
  FixedPoint y1(ismax, dsmax, y);
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_eq++;
  
  return (x1.number == y1.number);
}

bool operator !=  (const FixedPoint &x, const FixedPoint &y) {
  
  if ((x.decsize == y.decsize) && (x.intsize == y.intsize))
    return (x.number != y.number);
  
  unsigned int dsmax = (x.decsize > y.decsize) ? x.decsize : y.decsize;
  unsigned int ismax = (x.intsize > y.intsize) ? x.intsize : y.intsize;
  
  FixedPoint x1(ismax, dsmax, x);
  FixedPoint y1(ismax, dsmax, y);
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_neq++;
  
  return (x1.number != y1.number);
}

bool operator >  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1, y1;
  
  if ((x.decsize != y.decsize) || (x.intsize != y.intsize)) {
    unsigned int dsmax = (x.decsize > y.decsize) ? x.decsize : y.decsize;
    unsigned int ismax = (x.intsize > y.intsize) ? x.intsize : y.intsize;
    
    x1 = FixedPoint(ismax, dsmax, x);
    y1 = FixedPoint(ismax, dsmax, y);
  }
  else {
    x1 = x;
    y1 = y;
  }
  
  char x1_sign = x1.signbit();
  char y1_sign = y1.signbit();
  
  if (x1_sign == y1_sign)
    return (x1.number > y1.number);
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_gt++;
  
  return (x1_sign == 0);
}

bool operator >=  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1, y1;
  
  if ((x.decsize != y.decsize) || (x.intsize != y.intsize)) {
    unsigned int dsmax = (x.decsize > y.decsize) ? x.decsize : y.decsize;
    unsigned int ismax = (x.intsize > y.intsize) ? x.intsize : y.intsize;
    
    x1 = FixedPoint(ismax, dsmax, x);
    y1 = FixedPoint(ismax, dsmax, y);
  }
  else {
    x1 = x;
    y1 = y;
  }
  
  char x1_sign = x1.signbit();
  char y1_sign = y1.signbit();
  
  if (x1_sign == y1_sign)
    return (x1.number >= y1.number);
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_ge++;
  
  return (x1_sign == 0);
}

bool operator <  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1, y1;
  
  if ((x.decsize != y.decsize) || (x.intsize != y.intsize)) {
    unsigned int dsmax = (x.decsize > y.decsize) ? x.decsize : y.decsize;
    unsigned int ismax = (x.intsize > y.intsize) ? x.intsize : y.intsize;
    
    x1 = FixedPoint(ismax, dsmax, x);
    y1 = FixedPoint(ismax, dsmax, y);
    }
  else {
    x1 = x;
    y1 = y;
  }
  
  char x1_sign = x1.signbit();
  char y1_sign = y1.signbit();
  
  if (x1_sign == y1_sign)
    return (x1.number < y1.number);
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_lt++;
  
  return (x1_sign != 0);
}

bool operator <=  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1, y1;
  
  if ((x.decsize != y.decsize) || (x.intsize != y.intsize)) {
    unsigned int dsmax = (x.decsize > y.decsize) ? x.decsize : y.decsize;
    unsigned int ismax = (x.intsize > y.intsize) ? x.intsize : y.intsize;
    
    x1 = FixedPoint(ismax, dsmax, x);
    y1 = FixedPoint(ismax, dsmax, y);
  }
  else {
    x1 = x;
    y1 = y;
  }
  
  char x1_sign = x1.signbit();
  char y1_sign = y1.signbit();
  
  if (x1_sign == y1_sign)
    return (x1.number <= y1.number);
  
  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_le++;
  
  return (x1_sign != 0);
}

/* FixedPoint shifting functions */

FixedPoint rshift(const FixedPoint &x, int s) {
  FixedPoint t(x);
  
  while (s--) {
    t.decsize++;
    if (t.intsize)
      t.intsize--;
  }
  
  if (t.decsize+t.intsize > maxfixedsize) 
      fixed_error (Fixed::WRONGFIXSIZE);
  
  return t;
}

FixedPoint lshift(const FixedPoint &x, int s) {
  FixedPoint t(x);
  
  while (s--) {
    t.intsize++;
    if (t.decsize)
      t.decsize--;
  }

  if (t.decsize+t.intsize > maxfixedsize)
    fixed_error (Fixed::WRONGFIXSIZE);
  
  return t;
}

/* These are to simplify things for Octave */
FixedPoint real  (const FixedPoint &x) {
  return x;
}

FixedPoint imag  (const FixedPoint &x) {
  return FixedPoint(x.intsize, x.decsize);
}

FixedPoint conj  (const FixedPoint &x) {
  return x;
}

/* FixedPoint mathematic functions */

FixedPoint abs  (const FixedPoint &x) {
  if (x.signbit()) {
    FixedPoint t(x);
    t.number = (-x.number)&x.filter;

    if (Fixed::FP_Debug)
      t.value = -x.value;

  if (Fixed::FP_CountOperations)
      Fixed::FP_Operations.nb_neg++;

    return (t);
  }

  return (x);
}

#define FRIEND_FIXEDPOINT_MFUNC(FUNC) \
  FixedPoint FUNC  (const FixedPoint &x) \
  { \
    if (Fixed::FP_CountOperations) \
      Fixed::FP_Operations.nb_##FUNC++; \
    return (FixedPoint(x.intsize, x.decsize, FUNC(x.fixedpoint()))); \
  }

#define FRIEND_FIXEDPOINT_MFUNC_LOWER(FUNC, lower) \
  FixedPoint FUNC  (const FixedPoint &x) \
  { \
    double value = x.fixedpoint(); \
    if (value < lower) \
      { fixed_error (Fixed::BADMATH); return FixedPoint(); } \
    if (Fixed::FP_CountOperations) \
      Fixed::FP_Operations.nb_##FUNC++; \
    return FixedPoint(x.intsize, x.decsize, FUNC(value)); \
  }

#define FRIEND_FIXEDPOINT_MFUNC_UPPER(FUNC, upper) \
  FixedPoint FUNC  (const FixedPoint &x) \
  { \
    double value = x.fixedpoint(); \
    if (value > upper) \
      { fixed_error (Fixed::BADMATH); return FixedPoint(); } \
    if (Fixed::FP_CountOperations) \
      Fixed::FP_Operations.nb_##FUNC++; \
    return FixedPoint(x.intsize, x.decsize, FUNC(value)); \
  }

#define FRIEND_FIXEDPOINT_MFUNC_RANGE(FUNC, upper, lower) \
  FixedPoint FUNC  (const FixedPoint &x) \
  { \
    double value = x.fixedpoint(); \
    if ((value < lower) || (value > upper)) \
      { fixed_error (Fixed::BADMATH); return FixedPoint(); } \
    if (Fixed::FP_CountOperations) \
      Fixed::FP_Operations.nb_##FUNC++; \
    return FixedPoint(x.intsize, x.decsize, FUNC(value)); \
  }

FRIEND_FIXEDPOINT_MFUNC (cos);
FRIEND_FIXEDPOINT_MFUNC (cosh);
FRIEND_FIXEDPOINT_MFUNC (sin);
FRIEND_FIXEDPOINT_MFUNC (sinh);
FRIEND_FIXEDPOINT_MFUNC (tan);
FRIEND_FIXEDPOINT_MFUNC (tanh);
FRIEND_FIXEDPOINT_MFUNC_LOWER (sqrt,0.);

#define FRIEND_FIXEDPOINT_POW(TYPE) \
  FixedPoint pow  (const FixedPoint &x, const TYPE y) \
  { \
    if (Fixed::FP_CountOperations) \
      Fixed::FP_Operations.nb_pow++; \
    return (FixedPoint(x.intsize, x.decsize, std::pow(x.fixedpoint(), y))); \
  }

FRIEND_FIXEDPOINT_POW (int);
FRIEND_FIXEDPOINT_POW (double);

FixedPoint pow (const FixedPoint &x, const FixedPoint &y) {

  if (Fixed::FP_CountOperations) \
    Fixed::FP_Operations.nb_pow++;

  return (FixedPoint(x.intsize, x.decsize,
		     pow(x.fixedpoint(), y.fixedpoint())));
}

FRIEND_FIXEDPOINT_MFUNC (exp);
FRIEND_FIXEDPOINT_MFUNC_LOWER (log,0.);
FRIEND_FIXEDPOINT_MFUNC_LOWER (log10,0.);

FixedPoint atan2 (const FixedPoint &x, const FixedPoint &y) {

  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_atan2++;

  return (FixedPoint(x.intsize, x.decsize,
		     atan2(x.fixedpoint(), y.fixedpoint())));
}

FixedPoint round (const FixedPoint &x) {

  if (Fixed::FP_CountOperations)
    Fixed::FP_Operations.nb_round++;

  return (FixedPoint(x.intsize, x.decsize, floor(x.fixedpoint() + 0.5)));
}

FRIEND_FIXEDPOINT_MFUNC (rint);
FRIEND_FIXEDPOINT_MFUNC (floor);
FRIEND_FIXEDPOINT_MFUNC (ceil);

std::istream &operator >>  (std::istream &is, FixedPoint &x) {

  double d;
  
  is >> d;

  FixedPoint z(x.intsize, x.decsize, d);
  x.number = z.number;
  
  if (Fixed::FP_Debug)
    x.value = x.fixedpoint();

  return (is);
}  

std::ostream &operator <<  (std::ostream &os, const FixedPoint &x) {

  /*
    Extract number without sign.
  */

  fp_uint num = (x.signbit()) ? (-x.number)&x.filter : x.number;

  /*
    Extract integer and decimal part.
  */

  fp_uint i = num >> x.decsize;
  fp_uint d = (num & ((x.filter >> x.intsize+1) & x.filter));

  /*
    Print sign.
  */

  if (x.signbit())
    os << "-";

  /*
    Print integer part.
  */

  os << i;

  /*
    Process decimal part.
  */

  if (x.decsize) {

    /*
      Print decimal dot.
    */

    os  << ".";

    /*
      Table of 5 power from 0 to bit number of "fp_uint"
    */

    const int nb_digits = SIZEOF_FIXED * 8;
    const int nb_digits_1 = nb_digits-1;

    /*
      Create decimal part as a string and compute its length.
    */

    char dec[nb_digits];
    int dec_len = 0;
    while (d > 0) {
      dec[nb_digits_1-dec_len] = d%10;
      dec_len++;
      d /= 10;
    }
      
    /*
      Create and initialize result string.
    */

    char res[nb_digits];
    for (int k=0; k<nb_digits; k++)
      res[k] = 0;

    /*
      Multiply 5^x.decsize by decimal part.
    */

    for (int k=0; k<nb_digits; k++) {

      int val = pow5[x.decsize][nb_digits_1-k];

      for (int l=0; l<dec_len; l++) {
	int digit = l + k;
	int tmp = (res[nb_digits_1-digit]) + (dec[nb_digits_1-l])*val;
	while (tmp > 0) {
	  res[nb_digits_1-digit] = (tmp%10);
	  digit++;
	  tmp /= 10;
	  tmp += (res[nb_digits_1-digit]);
	}
      }
    }

    for (int k=nb_digits-x.decsize; k<nb_digits;k++)
      os << char(res[k]+'0');

  }

  return (os);
}

std::string getbitstring (const FixedPoint &x) {

  int l = x.intsize+x.decsize+1;
  fp_uint nb = x.number;
  
  std::string st(l, ' ');

  for (int i=1; i<=l; i++) {
    st[l-i] = '0'+ (nb&1);
    nb >>= 1;
  }

  return (st);
}

// FixedPoint operation summary

FixedPointOperation::FixedPointOperation() :
  nb_add(0), nb_sub(0), nb_mult(0), nb_div(0),
  nb_lshift(0), nb_rshift(0),
  nb_inc(0), nb_dec(0),
  nb_neg(0), nb_comp(0),
  nb_eq(0), nb_neq(0), nb_gt(0), nb_ge(0), nb_lt(0), nb_le(0),
  nb_cos(0), nb_cosh(0), nb_sin(0), nb_sinh(0), nb_tan(0), nb_tanh(0),
  nb_sqrt(0), nb_pow(0), nb_exp(0), nb_log(0), nb_log10(0),
  nb_atan2(0),
  nb_round(0), nb_rint(0), nb_floor(0), nb_ceil(0) {}

void FixedPointOperation::reset () {

  nb_add = nb_sub = nb_mult = nb_div = 0;
  nb_lshift = nb_rshift = 0;
  nb_inc = nb_dec = 0;
  nb_neg = nb_comp = 0;
  nb_eq = nb_neq = nb_gt = nb_ge = nb_lt = nb_le = 0;
  nb_cos = nb_cosh = nb_sin = nb_sinh = nb_tan = nb_tanh = 0;
  nb_sqrt = nb_pow = nb_exp = nb_log = nb_log10 = 0;
  nb_atan2 = 0;
  nb_round = nb_rint = nb_floor = nb_ceil = 0;
}

std::ostream &operator << (std::ostream &os, const FixedPointOperation &x) {

  os << "Summary of FixedPoint operations" << std::endl;
  os << "================================" << std::endl;

  os << "Number of additions: " << x.nb_add << std::endl;
  os << "Number of subtractions: " << x.nb_sub << std::endl;
  os << "Number of multiplications: " << x.nb_mult << std::endl;
  os << "Number of divisions: " << x.nb_div << std::endl;
  os << std::endl;

  os << "Number of left shifts: " << x.nb_lshift << std::endl;
  os << "Number of right shifts: " << x.nb_rshift << std::endl;
  os << std::endl;

  os << "Number of increments: " << x.nb_inc << std::endl;
  os << "Number of decrements: " << x.nb_dec << std::endl;
  os << std::endl;

  os << "Number of negations: " << x.nb_neg << std::endl;
  os << "Number of bitwise not: " << x.nb_comp << std::endl;
  os << std::endl;

  os << "Number of equalities: " << x.nb_eq << std::endl;
  os << "Number of inequalities: " << x.nb_neq << std::endl;
  os << "Number of greater than: " << x.nb_gt << std::endl;
  os << "Number of greater than or equal to: " << x.nb_ge << std::endl;
  os << "Number of less than: " << x.nb_lt << std::endl;
  os << "Number of less than or equal to: " << x.nb_le << std::endl;
  os << std::endl;

  os << "Number of cosine calculations: " << x.nb_cos << std::endl;
  os << "Number of hyperbolic cosine calculations: " << x.nb_cosh << std::endl;
  os << "Number of sine calculations: " << x.nb_sin << std::endl;
  os << "Number of hyperbolic sine calculations: " << x.nb_sinh << std::endl;
  os << "Number of tangent calculations: " << x.nb_tan << std::endl;
  os << "Number of hyperbolic tangent calculations: " << x.nb_tanh << std::endl;
  os << std::endl;

  os << "Number of square roots: " << x.nb_sqrt << std::endl;
  os << "Number of power calculations: " << x.nb_pow << std::endl;
  os << "Number of exponentials: " << x.nb_exp << std::endl;
  os << "Number of logarithms: " << x.nb_log << std::endl;
  os << "Number of base 10 logarithms: " << x.nb_log10 << std::endl;
  os << std::endl;

  os << "Number of arc-tangent calculations: " << x.nb_atan2 << std::endl;
  os << std::endl;

  os << "Number of round operations: " << x.nb_round << std::endl;
  os << "Number of rint operations: " << x.nb_rint << std::endl;
  os << "Number of floor operations: " << x.nb_floor << std::endl;
  os << "Number of ceil operations: " << x.nb_ceil << std::endl;
  os << std::endl;

  return os;
}

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
