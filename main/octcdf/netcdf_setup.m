## Copyright (C) 2005 Alexander Barth
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
## This script should be called from you .octaverc file if you have the
## the dispatch function from octave-forge installed. It allows you 
## to drop the "nc" prefix of various octcdf functions and to increase the
## compatability with the Matlab NetCDF toolbox.

## Author: Alexander Barth <abarth@marine.usf.edu>

dispatch('close','ncclose','ncfile');
dispatch('redef','ncredef','ncfile');
dispatch('endef','endef','ncfile');
dispatch('sync','ncsync','ncfile');

dispatch('var','ncvar','ncfile');

dispatch('att','ncatt','ncfile');
dispatch('att','ncatt','ncvar');

dispatch('dim','ncdim','ncfile');
dispatch('dim','ncdim','ncvar');

dispatch('name','ncname','ncfile');
dispatch('name','ncname','ncvar');
dispatch('name','ncname','ncatt');
dispatch('name','ncname','ncdim');

dispatch('datatype','ncdatatype','ncvar');
dispatch('datatype','ncdatatype','ncatt');
