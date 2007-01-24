/*
Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
OdePkg - Package for solving ordinary differential equations with octave

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#ifndef __ODEPKGEXT__
#define __ODEPKGEXT__ 1

extern bool fodepkgvar   (const unsigned int vdeci, const char *vname, mxArray **vvalue);
extern bool fsolstore    (unsigned int vdeci, mxArray **vt, mxArray **vy);
extern bool fy2mxArray   (unsigned int n, double *y, mxArray **vval);
extern bool fodepkgplot  (mxArray *vtime, mxArray *vvalues, mxArray *vdeci);
extern bool fodepkgevent (mxArray *vtime, mxArray *vvalues, mxArray *vdeci, mxArray **vval);
#endif /* __ODEPKGEXT__ */

/*
Local Variables: ***
mode: C ***
End: ***
*/
