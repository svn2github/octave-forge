/*
  octcdf, a netcdf toolbox for octave 
  Copyright (C) 2005 Alexander Barth <barth.alexander@gmail.com>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; If not, see <http://www.gnu.org/licenses/>.
*/


#include "ov-netcdf.h"
#include "ov-ncfile.h"
#include "ov-ncvar.h"
#include "ov-ncatt.h"



//
// Constructors of octave_ncvar
//

octave_ncvar::octave_ncvar(octave_ncfile* ncfilep, std::string varnamep) :octave_base_value() {
  int status, varid;

  ncv = new ncvar_t;
# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new ncvar " << ncv << endl;
# endif

  set_ncfile(ncfilep);
  set_varname(varnamep);
  set_ncid(ncfilep->get_ncid());

  status = nc_inq_varid(get_ncid(),get_varname().c_str(), &varid);

  if (status != NC_NOERR)  {
    error("Error while querying variable %s: %s",
	  get_varname().c_str(), nc_strerror(status));
    return;
  }

  set_varid(varid);

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new variable " <<  __LINE__ << ":"  << __FUNCTION__ << std::endl;
# endif

  read_info();

  autoscale() = false;
  autonan() = false;
  ncv->count = 1;
}


octave_ncvar::octave_ncvar(octave_ncfile* ncfilep, int varidp):octave_base_value() {

  ncv = new ncvar_t;
# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new ncvar " << ncv << endl;
# endif

  set_varid(varidp);
  set_ncfile(ncfilep);
  set_ncid(ncfilep->get_ncid());  

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new variable " <<  __LINE__ << ":" << __FUNCTION__ << std::endl;
# endif

  read_info();

  autoscale() = false;
  autonan() = false;
  ncv->count = 1;
}

// destructor

octave_ncvar::~octave_ncvar() {

    if (!ncv) {
      // nothing to do
#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "ncv already NULL " << ncv  << endl;
#     endif
      return;
    }

    ncv->count--;
#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "ncv count " << count << endl;
#   endif
    if (ncv->count == 0) {
#      ifdef OV_NETCDF_VERBOSE
       octave_stdout << "delete ncv " << ncv << endl;
#      endif
       delete ncv->ncfile;
       delete ncv;
       ncv = NULL;
    }
 }

// load charecteristics of netcdf variable from file

void octave_ncvar::read_info() {

  int status;
  int dimids[NC_MAX_VAR_DIMS];
  int ndims, natts;
  char name[NC_MAX_NAME];
  size_t length;
  nc_type nctype;
  dim_vector dimvec;
  vector<int> ncdimvec;
  std::list<std::string> dimnames;

  if (get_varid() == -1) return;

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << __FILE__ <<  __LINE__ << ":" << __FUNCTION__ << std::endl;
# endif

  status = nc_inq_var(get_ncid(),get_varid(),name,&nctype,&ndims,dimids,&natts);

  if (status != NC_NOERR) {
    error("Error while querying variable: %s",nc_strerror(status));
    return;
  }

  set_nctype(nctype);
  set_natts(natts);

  set_varname(string(name));
  //if (ndims > 2)
  ncdimvec.resize(ndims);

  // octave dimvec
  // Number of dimensions is at least 2
  dimvec.resize(max(ndims,2));

  // reverse dimids if FORTRAN_ORDER

  if (STORAGE_ORDER == FORTRAN_ORDER) 
    for (int i=0; i<ndims/2; i++) {
      status = dimids[i];
      dimids[i] = dimids[ndims-i-1];
      dimids[ndims-i-1] = status;
    }

  for (int i=0; i<ndims; i++) {
    status = nc_inq_dim(get_ncid(),dimids[i],name,&length);
  
    if (status != NC_NOERR)
      error("Error while querying dimenstion: %s",nc_strerror(status));

    set_dimid(i,dimids[i]);
    dimnames.push_back(name);  
    ncdimvec[i] = length;
    dimvec(i) = length;
  }


  // fill remaining dimvec's with 1

  if (ndims == 0) {
    dimvec(0) = 1;
    dimvec(1) = 1;
  }
  else if (ndims == 1) {
    dimvec(1) = 1;
  }

  ncv->dimvec = dimvec;
  ncv->ncdimvec = ncdimvec;
  set_dimnames(dimnames);
}




// Assigmnent of the type:
// x.v = y     x(idx).v = y     x{idx}.v = y

octave_value octave_ncvar::subsasgn(const std::string & type,
			       const std::list < octave_value_list > &idx,
			       const octave_value & rhs) {
  octave_value scale_factor, add_offset, scaledrhs;
  octave_value fillvalue;
  octave_value retval;

  switch (type[0])
    {
    case '.':
      {
	std::string name = idx.front()(0).string_value();

	// convention of netcdf matlab toolbox
        if (name == "FillValue_")
	  name = "_FillValue";

	get_ncfile()->set_mode(DefineMode);
#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "create attribute " << name << std::endl;
#       endif


	if (!rhs.is_cell()) {
          nc_type nctype = ovtype2nctype(rhs);
          ov_nc_put_att(get_ncid(),get_varid(),name,nctype,rhs);
	}
        else {
#         ifdef OV_NETCDF_VERBOSE
	  octave_stdout << "define attribute from cell " << get_ncid() << std::endl;
#         endif

          Cell c =  rhs.cell_value();
          nc_type nctype = ncname2nctype(c.elem(0).string_value());
   	  ov_nc_put_att(get_ncid(),get_varid(),name,nctype,c.elem(1));
	}



	break;
      }
    case '(':
      {
#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "putting var " << std::endl;
#       endif

        scaledrhs = rhs;

	// autoscale the retrieved variable if necessary
	// the variables attributes "scale_factor" and "add_offset" are
	// used for the linear scale if present.

	if (autoscale()) {
	  add_offset = ov_nc_get_att(get_ncid(),get_varid(),"add_offset");

	  if (!add_offset.is_empty()) {
	    scaledrhs = scaledrhs - add_offset;
	  }

	  scale_factor = ov_nc_get_att(get_ncid(),get_varid(),"scale_factor");
 
	  if (!scale_factor.is_empty()) {
	    scaledrhs = scaledrhs / scale_factor;
	  }
	}


	//
	// replace NaN by _FillValue if requested
	//

	if (autonan()) {
	  fillvalue = ov_nc_get_att(get_ncid(),get_varid(),"_FillValue");

          if (!fillvalue.is_empty()) {
            if ( scaledrhs.numel() == 1) {
              if (lo_ieee_isnan(scaledrhs.scalar_value())) 
		scaledrhs = fillvalue;
	    }
            else
	      for (int i=0; i < scaledrhs.numel(); i++) {
		if (lo_ieee_isnan(scaledrhs.array_value().xelem(i)))
		  scaledrhs.array_value().xelem(i) = fillvalue.scalar_value();
	      }
	  }
	}


	get_ncfile()->set_mode(DataMode);
	octave_value_list key_idx = *idx.begin();
	std::list<Range> ranges = get_slice(key_idx);

#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "putting var " << __LINE__ << std::endl;
#       endif

        if (error_state)  return retval;
 
	ov_nc_put_vars(get_ncid(),get_varid(),ranges,get_nctype(),scaledrhs);

	retval = rhs;

#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "end putting var " << std::endl;
#       endif

	break;
      }
    case '{':
      {
	error("octave_ncvar cannout be referenced with {}");
	break;
      }
      break;

    }

  // update characteristics
  read_info();

# ifdef OCTAVE_VALUE_COUNT_CONSTRUCTOR
  retval = octave_value(this, count + 1);
# else
  retval = octave_value(clone());
# endif

  return retval;
};


// References of the type:
// x.v     x(idx)     x{idx}

octave_value octave_ncvar::subsref(const std::string & type,
			      const std::list < octave_value_list > &idx)
{
  octave_value scale_factor, add_offset;
  octave_value fillvalue;
  octave_value retval;


  switch (type[0])
    {
    case '.':
      {
	std::string name = idx.front()(0).string_value();

	// convention of netcdf matlab toolbox
        if (name == "FillValue_")
	  name = "_FillValue";


#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "getting attribute " << name << std::endl;
#       endif

	retval = ov_nc_get_att(get_ncid(),get_varid(),name);

	break;
      }
    case '(':
      {
#       ifdef OV_NETCDF_VERBOSE
	octave_stdout <<  __LINE__ << ":"  << __FUNCTION__ << "getting var " << std::endl;
#       endif
	get_ncfile()->set_mode(DataMode);
	octave_value_list key_idx = idx.front();
	std::list<Range> ranges = get_slice(key_idx);

        if (error_state)  return retval;

	retval = ov_nc_get_vars(get_ncid(),get_varid(),ranges,get_nctype());

	if (autonan()) {
	  fillvalue = ov_nc_get_att(get_ncid(),get_varid(),"_FillValue");

          if (!fillvalue.is_empty()) {
            for (int i=0; i<retval.numel(); i++)
	      if (retval.array_value().xelem(i) == fillvalue.scalar_value()) 
	        retval.array_value().xelem(i) = octave_NaN;
	  }
	}


	// autoscale the retrieved variable if necessary
	// the variables attributes "scale_factor" and "add_offset" are
	// used for the linear scale if present.

	if (autoscale()) {
	  scale_factor = ov_nc_get_att(get_ncid(),get_varid(),"scale_factor");
 
	  if (!scale_factor.is_empty()) {
	    retval = retval * scale_factor;
	  }

	  add_offset = ov_nc_get_att(get_ncid(),get_varid(),"add_offset");
	  if (!add_offset.is_empty()) {
	    retval = retval + add_offset;
	  }
	}

	break;
      }
    case '{':
      {
	error("octave_ncvar cannot not be indexed with {}");
	break;
      }
      break;

    }

  // apply remaining subreference operator

  return retval.next_subsref(type, idx);
}


void  octave_ncvar::print(std::ostream & os, bool pr_as_read_syntax = false) const
{
  int i;

  os << "varname = \"" << get_varname() << "\"" << std::endl;
  os << "type = " << nctype2ncname(get_nctype()) << endl;;
# ifdef OV_NETCDF_VERBOSE
  os << "ncid = " << get_ncid() << std::endl;
  os << "varid = " << get_varid() << std::endl;
# endif
  os << "natts = " << get_natts() << std::endl;

  os << "autoscale = " << (int)autoscale() << std::endl;
  os << "autonan = " << (int)autonan() << std::endl;

  os << "size = " << dims().str() << std::endl;
  //  os << "ncsize = " << ncv->ncdimvec.str() << std::endl;

//   os << "size = ";
//   for (i=0; i<ndims()-1; i++) {
//     os << ncv->dimvec(i) << " x ";
//   }
  
//   os << ncv->dimvec(ndims()-1) << std::endl;

  //  std::list<std::string> dimnames = get_dimnames();
  std::list<std::string>::const_iterator it;

  i=1;
  for(it=ncv->dimnames.begin(); it!=ncv->dimnames.end(); ++it) {
    os << "dimension " << i << " = "  << *it << std::endl;
    os << "dimension id " << i << " = "  << ncv->dimids[i-1] << std::endl;
    i=i+1;
  } 


}


// determine the slice of the variable to read or to store depending 
// on the ranges given in key_idx
// ranges contains ncndims elements

std::list<Range> octave_ncvar::get_slice(octave_value_list key_idx)
{
  //std::string key = key_idx(0).string_value ();

  std::list<Range> ranges;

  // special case: if only one colone, then retrieve all data

  if (key_idx.length() == 1 && key_idx(0).is_magic_colon())
    {
      for (int i = 0; i < ncndims(); i++)
	{
	  ranges.push_back(Range(1. , (double)dims()(i), 1.));
	}
    }
  else
    {
      for (int i = 0; i < ncndims(); i++)
	{
	  if (key_idx(i).is_range())  {
	      ranges.push_back(key_idx(i).range_value());
	    }
	  else if (key_idx(i).is_magic_colon()) {
	      ranges.push_back(Range(1. , (double)dims()(i)));
	    }
	  else if (key_idx(i).is_real_scalar())  {
              ranges.push_back(Range(key_idx(i).scalar_value(),key_idx(i).scalar_value()));
	  }
	  else if (key_idx(i).is_matrix_type())  {
            Matrix m =  key_idx(i).matrix_value();

            if (m.rows() != 1) m = m.transpose();
              
            Range r = Range(m(0),m(m.numel()-1),m(1)-m(0));

            if (r.inc() <= 0) {
   	      error("octcdf: indexes must be increasing");
   	      return ranges;
	    }

            if (r.matrix_value() != m) {
   	      error("octcdf: indexes must be contiguous");
   	      return ranges;
	    }

            ranges.push_back(r);
	  }
          else {
 	    error("octcdf: unknown index specification: type %s",key_idx(i).type_name().c_str());
	    return ranges;
	  }
	}
    }


  if (STORAGE_ORDER == FORTRAN_ORDER)
     ranges.reverse();

  return ranges;
}



void octave_ncvar::rename(string new_name) {
  int status;
    
  status = nc_rename_var(get_ncid(),get_varid(), new_name.c_str()); 

  if (status != NC_NOERR) {
    error("Error while renaming variable %s: %s", get_varname().c_str(),
	  nc_strerror(status));
    return;
  }

  set_varname(new_name);
}

#ifdef DEFINE_OCTAVE_ALLOCATOR
DEFINE_OCTAVE_ALLOCATOR(octave_ncvar);
#endif
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(octave_ncvar, "ncvar", "ncvar");

// end octave_ncvar

