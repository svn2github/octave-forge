# Copyright (C) 2007   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{m}] =} amdemod(@var{s},@var{fc},@var{fs})
##	Compute the amplitude demodulation of the signal S with a carrier freauency of fc and a sample frequency of fs.
## @seealso{ammod}
## @end deftypefn

function [m] = amdemod(s,fc,fs)
    e = abs(s);
    [b a] = butter(5,fc./fs);
    m = filter(b,a,e);
    m = m-mean(m);