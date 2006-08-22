/*

Copyright (C) 2003 Motorola Inc
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
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (fixed_conv_h)
#define fixed_conv_h 1

#include <octave/config.h>

#ifdef HAVE_HDF5
#include <hdf5.h>
hid_t hdf5_make_fixed_complex_type (hid_t num_type, int size);
#endif

#define LS_DO_WRITE(TYPE, data, size, len, stream) \
  do \
    { \
      if (len > 0) \
	{ \
	  TYPE *ptr = new TYPE [len]; \
	  for (int i = 0; i < len; i++) \
	    ptr[i] = X_CAST (TYPE, (data)[i]); \
	  stream.write (X_CAST (char *, ptr), size * len); \
	  delete [] ptr ; \
	} \
    } \
  while (0)

#define LS_DO_READ(TYPE, swap, data, size, len, stream) \
  do \
    { \
      if (len > 0) \
	{ \
	  TYPE *ptr = new TYPE [len]; \
	  stream.read (X_CAST (char *, ptr), size * len); \
	  if (swap) \
	    swap_bytes <size> (ptr, len); \
	  for (int i = 0; i < len; i++) \
	    (data)[i] = ptr[i]; \
	  delete [] ptr ; \
	} \
    } \
  while (0)

#define LS_DO_READ_1(data, len, stream) \
  do \
    { \
      if (len > 0) \
	{ \
	  char *ptr = new char [len]; \
	  stream.read (X_CAST (char *, ptr), len); \
	  for (int i = 0; i < len; i++) \
	    (data)[i] = ptr[i]; \
	  delete [] ptr ; \
	} \
    } \
  while (0)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
