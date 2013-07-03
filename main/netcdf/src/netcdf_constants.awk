# Copyright (C) 2013 Alexander Barth
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; If not, see <http://www.gnu.org/licenses/>.

# Generate the list of NetCDF constants based on the header file netcdf.h

BEGIN {
  print "// DO NOT EDIT -- generated by netcdf_constants.awk";
} 
/\#define[ \t]+NC_[0-9a-zA-Z_]*[ \t]+/ { 
    constant=$2;
    ov = constant;

    if ($0 ~ /.*internally.*/ || constant == "NC_TURN_OFF_LOGGING") {
	next;
    }

    if (constant ~ /NC_.*_BYTE/) {
      ov = "octave_int8(" constant ")";
    }
    else if (constant ~ /NC_.*_UBYTE/) {
      ov = "octave_uint8(" constant ")";
    }
    else if (constant ~ /NC_.*_SHORT/) {
      ov = "octave_int16(" constant ")";
    }
    else if (constant ~ /NC_.*_USHORT/) {
      ov = "octave_uint16(" constant ")";
    }
    else if (constant ~ /NC_.*_INT/) {
      ov = "octave_int32(" constant ")";
    }
    else if (constant ~ /NC_.*_UINT/) {
      ov = "octave_uint32(" constant ")";
    }
    else if (constant ~ /NC_.*_INT64/) {
      ov = "octave_int64(" constant ")";
    }
    else if (constant ~ /NC_.*_UINT64/) {
      ov = "octave_uint64(" constant ")";
    }
    else if (constant ~ /NC_.*_CHAR/) {
      ov = "(char)" constant;
    }
    else if (constant ~ /NC_.*_STRING/) {
      ov = "std::string(" constant ")";
    }
    else if (constant ~ /NC_.*_FLOAT/) {
      ov = "(float)" constant;
    }
    else if (constant ~ /NC_.*_STRING/) {
      ov = "(double)" constant;
    }

    printf "  netcdf_constants[\"%s\"] = octave_value(%s);\n",constant,ov;
}
