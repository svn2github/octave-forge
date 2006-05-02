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



#include "ov-netcdf.h"
#include "ov-ncfile.h"
#include "ov-ncdim.h"



//
// octave_ncdim
//


octave_ncdim::octave_ncdim(octave_ncfile* ncfilep, int dimid) {
  int status, unlimdimid;
  char name[NC_MAX_NAME];
  size_t len;

#   ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new dim " <<  __LINE__ << ":"  << __FUNCTION__ << " dimid " <<dimid<< std::endl;
#  endif

    ncd = new ncdim_t;

     set_ncfile(ncfilep);
     set_dimid(dimid);

     //octave_stdout << "ncid " << ncid << endl;

     status = nc_inq_dim(get_ncid(),get_dimid(),name,&len);

       //status = nc_inq_dimname(get_ncid(),get_dimid(),name);
    set_name(string(name));
    set_length(len);

    status = nc_inq_unlimdim(get_ncid(),&unlimdimid);

    set_record(dimid == unlimdimid);

    //     read_info();
  }
   


// // ncdim_var(:) = y

// octave_value octave_ncdim::subsasgn(const std::string & type,
// 				const LIST < octave_value_list > &idx,
// 				const octave_value & rhs)
// {
//   int status;
//   octave_value retval;

// # ifdef OV_NETCDF_VERBOSE
//   octave_stdout << "setting attribute value " << std::endl;
// # endif

// # ifdef OCTAVE_VALUE_COUNT_CONSTRUCTOR
//   retval = octave_value(this, count + 1);
// # else
//   retval = octave_value(clone());
// # endif
//   return retval;
// };

// ncdim_var(:) 

octave_value octave_ncdim::subsref(const std::string SUBSREF_STRREF type,
			       const LIST < octave_value_list > &idx)
{
  int dimid, status, varid;
  size_t length;
  octave_value retval;

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "getting dimension length " << std::endl;
# endif


  if (type[0] != '(' || !idx.front()(0).is_magic_colon() ) {
    error("A ncdim can only be referenced with a (:)");
    return octave_value();
  }

  return octave_value((int)get_length());

  //  return retval.next_subsref(type, idx);
}


  void octave_ncdim::read_info() {
  size_t length;
  int status;


  //dimvec.resize(length);
  }


  void octave_ncdim::print(std::ostream & os, bool pr_as_read_syntax) const {
    os << "dimname = " << get_name() << endl;;
    os << "length = " << get_length() << endl;;
    os << "is_record = " << is_record() << endl;;
  }

void octave_ncdim::rename(string new_name) {
  int status;
    
  status = nc_rename_dim(get_ncid(),get_dimid(), new_name.c_str()); 

  if (status != NC_NOERR) {
    error("Error while renaming dimension %s: %s", get_name().c_str(),
	  nc_strerror(status));
    return;
  }

  set_name(new_name);
}


DEFINE_OCTAVE_ALLOCATOR(octave_ncdim);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(octave_ncdim, "ncdim", "ncdim");


