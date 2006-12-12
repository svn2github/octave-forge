/*
  octcdf, a netcdf toolbox for octave 
  Copyright (C) 2005 Alexander Barth <abarth@marine.usf.edu>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/


#if !defined (octave_netcdf_int_h)
#define octave_netcdf_int_h 1

#include<iostream>
#include <octave/config.h>
#include<octave/oct.h>
#include<octave/parse.h>
#include<octave/dynamic-ld.h>
#include<octave/oct-map.h>
#include<octave/oct-stream.h>
#include <octave/ov-base.h>
#include<octave/ov-base-scalar.h>
#include<vector>
#include<string>
#include <netcdf.h>
#include <ArrayN.h>
#include <list>

#include "ov-uint64.h"
#include "ov-uint32.h"
#include "ov-uint16.h"
#include "ov-uint8.h"
#include "ov-int64.h"
#include "ov-int32.h"
#include "ov-int16.h"
#include "ov-int8.h"

#include "ov-scalar.h"
#include "ov-range.h"
#include "ov-cell.h"


#define STORAGE_ORDER 1
#define FORTRAN_ORDER 0
#define C_ORDER 1

//#define OCTCDF_64BIT_OFFSET 

//#define  OV_NETCDF_VERBOSE

//#define OCTAVE_VALUE_COUNT_CONSTRUCTOR


#ifdef HAVE_OCTAVE_21
#define octave_idx_type int
#define OCTAVE_PERMVEC_INDEX_ORIGIN 1 
#define print_usage() 
#else
#define OCTAVE_PERMVEC_INDEX_ORIGIN 0
#endif


#ifndef OV_REP_TYPE
#define OV_REP_TYPE octave_value
#endif


using namespace std;



dim_vector reverse(dim_vector dv);

typedef enum { DefineMode = 0, DataMode = 1 } Modes;





octave_value ov_nc_get_att(int ncid, int varid,const std::string name);
void ov_nc_put_att(int ncid, int varid,const std::string name,nc_type nctype,const octave_value rhs);

octave_value ov_nc_get_vars(int ncid, int varid,std::list<Range> ranges,nc_type nctype);
void ov_nc_put_vars(int ncid, int varid,std::list<Range> ranges,nc_type nctype,octave_value rhs);
void ov_nc_def_var(int ncid,std::string name,nc_type nctype, std::list<std::string> dimnames);


void check_args_string(std::string funname, octave_value_list args);

nc_type ovtype2nctype(const octave_value& val);
nc_type ncname2nctype(std::string name);
std::string nctype2ncname(nc_type type);

template <class ctype> ctype* ov_ctype(octave_value val,int& n);

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
