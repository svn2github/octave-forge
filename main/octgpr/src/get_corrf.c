/* Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
 * 
 * Author: Jaroslav Hajek <highegg@gmail.com>
 * 
 * This file is part of OctGPR.
 * 
 * OctGPR is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, see
 * <http://www.gnu.org/licenses/>.  */

#include <string.h>

#include "gprmod.h"
#include "forsubs.h"

corfptr get_corrf(const char *name)
{
  if (!strcmp(name,"gau") || !strcmp(name,"GAU"))
    return &F77_corgau;
  else if (!strcmp(name,"exp") || !strcmp(name,"EXP"))
    return &F77_corexp;
  else if (!strcmp(name,"imq") || !strcmp(name,"IMQ"))
    return &F77_corimq;
  else
    return NULL;
}
