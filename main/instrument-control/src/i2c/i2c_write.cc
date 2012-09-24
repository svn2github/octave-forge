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

#include "i2c_class.h"

static bool type_loaded = false;

DEFUN_DLD (i2c_write, args, nargout, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{n} = } i2c_write (@var{i2c}, @var{data})\n \
\n\
Write data to a i2c slave device.\n \
\n\
@var{i2c} - instance of @var{octave_i2c} class.@*\
@var{data} - data to be written to the slave device. Can be either of String or uint8 type.\n \
\n\
Upon successful completion, i2c_write() shall return the number of bytes written as the result @var{n}.\n \
@end deftypefn")
{
    if (!type_loaded)
    {
        octave_i2c::register_type();
        type_loaded = true;
    }

    
    if (args.length() != 2 || args(0).type_id() != octave_i2c::static_type_id()) 
    {
        print_usage();
        return octave_value(-1);
    }
    
    octave_i2c* i2c = NULL;

    const octave_base_value& rep = args(0).get_rep();
    i2c = &((octave_i2c &)rep);

    const octave_base_value& data = args(1).get_rep();
    int retval;
    
    if (data.is_string())
    {
        string buf = data.string_value();
        retval = i2c->write((unsigned char*)buf.c_str(), buf.length());
    }
    else if (data.byte_size() == data.numel())
    {
        NDArray dtmp = data.array_value();
        unsigned char* buf = new unsigned char [dtmp.length()];
        
        for (int i = 0; i < dtmp.length(); i++)
            buf[i] = (unsigned char)dtmp(i);
        
        retval = i2c->write(buf, data.byte_size());
        
        delete[] buf;
    }
    else
    {
        print_usage();
        return octave_value(-1);
    }

    return octave_value(retval);
}
