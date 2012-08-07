// Copyright (C) 2012   Andrius Sutas   <andrius.sutas@gmail.com>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <octave/ov-int32.h>
//#include <octave/ops.h>
//#include <octave/ov-typeinfo.h>

#include <iostream>
#include <string>
#include <algorithm>

#ifndef __WIN32__
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>
#endif

using std::string;

#include "serial.h"

// TODO: implement uint8 array as input type
// PKG_ADD: autoload ("srl_write", "serial.oct");
DEFUN_DLD (srl_write, args, nargout, "Hello World Help String")
{
    if (args.length() != 2) 
    {
        error("srl_write: expecting two arguments...");
        return octave_value(-1);
    }

    if (args(0).type_id() != octave_serial::static_type_id())
    {
        error("srl_write: expecting first argument of type octave_serial...");
        return octave_value(-1);
    }

    if (!args(1).is_string())
    {
        error("srl_write: expecting second argument of type string...");
        return octave_value(-1);
    }

    octave_serial* serial = NULL;

    const octave_base_value& rep = args(0).get_rep();
    serial = &((octave_serial &)rep);

    serial->srl_write(args(1).string_value());

    return octave_value();
}

int octave_serial::srl_write(string str)
{
    return ::write(srl_get_fd(), str.c_str(), str.length());
}