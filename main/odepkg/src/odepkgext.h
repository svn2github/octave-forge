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

#ifndef __ODEPKG_EXT__
#define __ODEPKG_EXT__ 1

#ifndef mwSize
#define mwSize int
#endif

#ifndef mwSize
#define mwSize int
#endif

#ifndef true
#define true 1
#endif

#ifndef false
#define false 0
#endif

void mexFixMsgTxt (const char *vfix);
void mexUsgMsgTxt (const char *vusg);

bool mxIsVector (const mxArray *vinp);
bool mxIsColumnVector (const mxArray *vinp);
bool mxIsRowVector (const mxArray *vinp);

#endif /* __ODEPKG_EXT__ */
