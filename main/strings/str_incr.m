## Copyright (C) 2001 Albert Danial <alnd@users.sf.net>
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

## usage: [new_name] = str_incr(old_name, nLetters);
##
##  Increments by one letter the substring comprising the first nLetters
##  of old_name.  The first nLetters may contain only characters in
##  'a'.. 'z'.
##  
##  Examples:  str_incr("aa",   2) returns "ab"  
##             str_incr("ab",   2) returns "ac"  
##             str_incr("az",   2) returns "ba"  
##             str_incr("zz",   2) returns an overflow error
##             str_incr("abcd", 2) returns "accd"  

function [new_name] = str_incr(old_name, nLetters);

    letters = toascii(old_name);
    if (nLetters > size(old_name, 2))
        error("str_incr:  2nd argument too large\n");
    endif

    for i = nLetters:-1:1

        # make sure the letter is in range
        if ( (letters(i) < toascii("a")) || (letters(i) > toascii("z")) )
            err_msg = sprintf(
            "str_incr: character %d not in 'a'..'z'\n", i);
            error(err_msg);
        endif

        if (letters(i) < toascii("z"))
            ++letters(i);
            break;
        elseif (i == 1)  # bummer, ran out of characters
            error("str_incr:  name length overflow\n");
        else
            letters(i) = toascii("a");
        endif

    endfor

    new_name = setstr(letters);
    return
endfunction
