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

#ifdef HAVE_CONFIG_H
#include "../config.h"
#endif

#ifdef BUILD_SERIAL
#include "serial_class.h"

static bool type_loaded = false;
#endif

DEFUN_DLD (srl_parity, args, nargout,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} srl_parity (@var{serial}, @var{parity})\n \
@deftypefnx {Loadable Function} {@var{p} = } srl_parity (@var{serial})\n \
\n\
Set new or get existing serial interface parity parameter. Even/Odd/None values are supported.\n \
\n\
@var{serial} - instance of @var{octave_serial} class.@*\
@var{parity} - parity value of type String. Supported values: Even/Odd/None (case insensitive, can be abbreviated to the first letter only).\n \
\n\
If @var{parity} parameter is omitted, the srl_parity() shall return current parity value as the result @var{p}.\n \
@end deftypefn")
{
#ifndef BUILD_SERIAL
    error("serial: Your system doesn't support the SERIAL interface");
    return octave_value();
#else
    if (!type_loaded)
    {
        octave_serial::register_type();
        type_loaded = true;
    }
    
    if (args.length() < 1 || args.length() > 2 || args(0).type_id() != octave_serial::static_type_id())
    {
        print_usage();
        return octave_value(-1);
    }
    
    octave_serial* serial = NULL;

    const octave_base_value& rep = args(0).get_rep();
    serial = &((octave_serial &)rep);

    // Setting new parity
    if (args.length() > 1)
    {
        if ( !(args(1).is_string()) )
        {
            print_usage();
            return octave_value(-1);
        }

        serial->set_parity(args(1).string_value());

        return octave_value();
    }

    // Returning current parity
    return octave_value(serial->get_parity());
#endif
}
