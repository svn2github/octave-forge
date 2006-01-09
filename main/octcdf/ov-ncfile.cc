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
#include "ov-ncvar.h"
#include "ov-ncatt.h"




octave_ncfile::octave_ncfile(string filenamep, string open_mode):octave_base_value()
{
  int status;
  int omode = NC_NOWRITE;
  bool do_open;

#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "allocate ncfile_t " << std::endl;
#    endif

  nf = new ncfile_t;

  nf->filename = filenamep;

  if (open_mode == "r" || open_mode == "nowrite") {
    do_open = true;
    omode = NC_NOWRITE;
  }
  else if (open_mode == "w" || open_mode == "write") {
    do_open = true;
    omode = NC_WRITE;
  }
  else if (open_mode == "c" || open_mode == "clobber") {
    do_open = false;
    omode = NC_CLOBBER;
  }
  else if (open_mode == "nc" || open_mode == "noclobber") {
    do_open = false;
    omode = NC_NOCLOBBER;
  }
  else {
    error("Unknown mode for opening netcdf file: %s",open_mode.c_str());
    return;
  }


  if (do_open)  {
      status = nc_open(nf->filename.c_str(), omode, &(nf->ncid));

      if (status != NC_NOERR)
	{
	  error("Error while opening %s: %s", nf->filename.c_str(),
		nc_strerror(status));
	  return;
	}


      nf->mode = DataMode;

    }
  else {
#     ifdef OCTCDF_64BIT_OFFSET 
      omode = omode | NC_64BIT_OFFSET;
#     endif

      status = nc_create(nf->filename.c_str(), omode, &(nf->ncid));

      if (status != NC_NOERR)
	{
	  error("Error while creating %s: %s", nf->filename.c_str(),
		nc_strerror(status));
	  return;
	}


      nf->mode = DefineMode;

    }

#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "Open file " << nf->filename.c_str() 
        << " omode " << omode << " mode " << (int) nf->mode << std::endl;
#    endif

    read_info();

}


void octave_ncfile::read_info() {

  int status;
  int dimids[NC_MAX_VAR_DIMS];
  char name[NC_MAX_NAME];
  size_t length;

  if (get_ncid() == -1) return;

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << __FILE__ <<  __LINE__ << ":" << __FUNCTION__ << std::endl;
# endif

  status = nc_inq(get_ncid(),&(nf->ndims),&(nf->nvars),&(nf->natts),&(nf->unlimdimid));

  if (status != NC_NOERR)
    error("Error while quering file: %s",nc_strerror(status));

}


// x.v = y     x(idx).v = y     x{idx}.v = y

octave_value octave_ncfile::subsasgn(const std::string & type,
				const LIST < octave_value_list > &idx,
				const octave_value & rhs)
{
  int status;
  octave_value retval;


  //  check_args_string("octave_ncfile::subsasgn",idx.front());

  if (error_state)
    return octave_value();

  std::string name = idx.front()(0).string_value();


  switch (type[0]) {
    case '.': {
#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "create attribute " << name << std::endl;
#       endif

	set_mode(DefineMode);

	if (!rhs.is_cell()) {

#           ifdef OV_NETCDF_VERBOSE
	    octave_stdout << "type_id" << rhs.type_id() << endl;
#           endif

            nc_type nctype = ovtype2nctype(rhs);

#          ifdef OV_NETCDF_VERBOSE
	    octave_stdout << "type " << nctype << endl;
#          endif

          ov_nc_put_att(get_ncid(),NC_GLOBAL,name,nctype,rhs);
	}
        else {
#       ifdef OV_NETCDF_VERBOSE
	  octave_stdout << "define attribute from cell " << get_ncid() << std::endl;
#       endif

            Cell c =  rhs.cell_value();

#           ifdef OV_NETCDF_VERBOSE
	    octave_stdout << "type " << c.elem(0).string_value()<< endl;
#           endif
            nc_type nctype = ncname2nctype(c.elem(0).string_value());
#           ifdef OV_NETCDF_VERBOSE
	    octave_stdout << "type " << nctype << endl;
#           endif
     	    ov_nc_put_att(get_ncid(),NC_GLOBAL,name,nctype,c.elem(1));
	}

	break;
      }
    case '(': {
	int dimid;
#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "create dimension " << name << std::endl;
#       endif

	set_mode(DefineMode);

	status =
	  nc_def_dim(get_ncid(),name.c_str(), (size_t) rhs.scalar_value(),
		     &dimid);

	if (status == NC_ENAMEINUSE) {
	  octave_stdout << "dimension " << name.c_str() << " already exist" << std::endl;
	}
        else if (status != NC_NOERR) {
	    error("Error while creating dimension %s: %s",
		  name.c_str(), nc_strerror(status));
	  }
	break;
      }
    case '{': {
	set_mode(DefineMode);

	if (type.length() == 1) {
	  if (rhs.class_name() == "ncvar") {
	    // define a variables

            // downcast from octave_value to octave_ncvar

            const octave_ncvar& ncvar = (const octave_ncvar&)rhs.get_rep();
#           ifdef OV_NETCDF_VERBOSE
  	    octave_stdout << "define variable " << name <<  " nctype " << ncvar.get_nctype() << std::endl;
#           endif

            ov_nc_def_var(get_ncid(),name,ncvar.get_nctype(),ncvar.get_dimnames());

	  } 
	  else if (rhs.is_cell()) {
#           ifdef OV_NETCDF_VERBOSE
  	    octave_stdout << "define variable from cell " << std::endl;
#           endif
            Cell c =  rhs.cell_value();

#           ifdef OV_NETCDF_VERBOSE
	    octave_stdout << "type " << c.elem(0).string_value()<< endl;
#           endif
            nc_type nctype = ncname2nctype(c.elem(0).string_value());
#           ifdef OV_NETCDF_VERBOSE
	    octave_stdout << "type " << nctype << endl;
#           endif

            std::list<std::string> dimnames;

            for (int i = 1; i < c.nelem(); i++) {
              dimnames.push_back(c.elem(i).string_value());
#             ifdef OV_NETCDF_VERBOSE
	      octave_stdout << "dimention " << c.elem(i).string_value()<< endl;
#             endif
            }

            ov_nc_def_var(get_ncid(),name,nctype,dimnames);

	  }
          else
	    error("Error rhs of assignment should be an ncvar");
	}
	else {
	  octave_ncvar *var = new octave_ncvar(this,name);

          if (idx.front().length() == 2) 
	    if (idx.front()(1).is_scalar_type()) 
              var->autoscale() = idx.front()(1).scalar_value() == 1;


            
	  if (! error_state && idx.size () > 1)
	    {
	      // make necessary assignment with netcdf variable

	      std::list<octave_value_list> new_idx (idx);
	      new_idx.erase (new_idx.begin ());
	      retval = var->subsasgn (type.substr(1), new_idx,rhs);
	    }

	}


	break;
      }
      break;

    }


  // update characteristics

  read_info();

  retval = octave_value(this, count + 1);
  return retval;


};

// x.v     x(idx).v     x{idx}.v

octave_value octave_ncfile::subsref(const std::string SUBSREF_STRREF type,
			       const LIST < octave_value_list > &idx)
{
  int dimid, status, varid;
  size_t length;
  octave_value retval;

  //  check_args_string("octave_ncfile::subsref",idx.front());

  if (error_state)
    return octave_value();

  std::string name = idx.front()(0).string_value();

  switch (type[0]) {
    case '.': {
#       ifdef OV_NETCDF_VERBOSE
	octave_stdout << "getting attribute " << name << std::endl;
#       endif

	retval = ov_nc_get_att(get_ncid(),NC_GLOBAL,name);

	break;
      }
    case '(':
      {
#       ifdef OV_NETCDF_VERBOSE
        octave_stdout << "getting dimension " << name << std::endl;
#       endif

	status = nc_inq_dimid(get_ncid(),name.c_str(), &dimid);

	if (status != NC_NOERR) {
	  error("Error while querying dimension %s: %s",name.c_str(), nc_strerror(status));
   	  return  octave_value();
	}

	status = nc_inq_dimlen(get_ncid(), dimid, &length);

	if (status != NC_NOERR) {
	  error("Error while querying dimension %s: %s",name.c_str(), nc_strerror(status));
   	  return  octave_value();
	}

	retval = octave_value(length);
	break;
      }
    case '{': {
#         ifdef OV_NETCDF_VERBOSE
	octave_stdout << "getting variable " << name << std::endl;
#         endif

	octave_ncvar *var = new octave_ncvar(this, name);

	// determine if the variable need to be scaled

        if (idx.front().length() == 2) {
            var->autoscale() = idx.front()(1).scalar_value() == 1;
	}

	retval = var;
	break;
      }
      break;

    }

  return retval.next_subsref(type, idx);
}


octave_ncfile::~octave_ncfile(void)
{
  // not a good idea to close file, since copies of ncfile are created 
  // which are destroyed when the original ncfile object is still used
  //  close();
}

void octave_ncfile::close(void) {
  int status;
#   ifdef OV_NETCDF_VERBOSE
  octave_stdout << "close file " << get_ncid() << std::endl;
#   endif

  if (get_ncid() == -1) return;

  status = nc_close(get_ncid());

   if (status != NC_NOERR)  {
       error("Error closing file: %s", nc_strerror(status));
     }

  nf->ncid = -1;
}

void octave_ncfile::sync(void) {
  int status;
#   ifdef OV_NETCDF_VERBOSE
  octave_stdout << "sync file " << std::endl;
#   endif

  set_mode(DataMode);
  status = nc_sync(get_ncid());

  if (status != NC_NOERR)
    {
      error("Error syncronizing file: %s", nc_strerror(status));
    }
}


void octave_ncfile::set_mode(Modes new_mode)
{
  int status;

  if (new_mode != get_mode())
    {
      if (new_mode == DataMode)
	  status = nc_enddef(get_ncid());
      else
	  status = nc_redef(get_ncid());

      if (status != NC_NOERR)
	  error("Error chaning mode: %s", nc_strerror(status));
      else
	  nf->mode = new_mode;
    }


}

void octave_ncfile::print(std::ostream & os, bool pr_as_read_syntax = false) const
{

  os << "filename = " << get_filename() << std::endl;
# ifdef OV_NETCDF_VERBOSE
  os << "ncid = " << get_ncid() << std::endl;
# endif
  os << "nvars = " << get_nvars() << std::endl;
  os << "natts = " << get_natts() << std::endl;
  os << "ndims = " << get_ndims() << std::endl;
  if (get_mode() == DataMode)
    os << "mode = DataMode " << std::endl;
  else
    os << "mode = DefineMode " << std::endl;
}




DEFINE_OCTAVE_ALLOCATOR(octave_ncfile);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(octave_ncfile, "ncfile", "ncfile");


// end octave_ncfile

