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
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02110-1301, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include "fixed-conv.h"

#ifdef HAVE_HDF5
hid_t
hdf5_make_fixed_complex_type (hid_t num_type, int size)
{
  hid_t type_id = H5Tcreate (H5T_COMPOUND, size * 2);

  H5Tinsert (type_id, "real", 0 * size, num_type);
  H5Tinsert (type_id, "imag", 1 * size, num_type);

  return type_id;
}
#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
