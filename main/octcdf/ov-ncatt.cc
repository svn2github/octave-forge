/*
  octcdf, a netcdf toolbox for octave 
  Copyright (C) 2005 Alexander Barth

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



//
// octave_ncatt
//

octave_ncatt::octave_ncatt(octave_ncvar* ncvar, int attnump) {
  int status;
  char name[NC_MAX_NAME];

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new attr " <<  __LINE__ << ":"  << __FUNCTION__ << std::endl;
# endif

  nca = new ncatt_t;

  set_ncfile(ncvar->get_ncfile());
  set_ncvar(ncvar);
  set_attnum(attnump);
  set_varid(ncvar->get_varid());
  set_ncid(ncvar->get_ncfile()->get_ncid());

  status = nc_inq_attname(get_ncid(),get_varid(),get_attnum(),name);

  if (status != NC_NOERR) {
    error("Error while quering attribute: %s",nc_strerror(status));
    return;
  }

  set_name(string(name));

  read_info();
}
   

octave_ncatt::octave_ncatt(octave_ncvar* ncvar, std::string attnamep) {
  int status, attnum;


# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new attr " <<  __LINE__ << ":"  << __FUNCTION__ << std::endl;
# endif

  nca = new ncatt_t;

  set_ncfile(ncvar->get_ncfile());
  set_ncvar(ncvar);
  set_name(attnamep);
  set_varid(ncvar->get_varid());
  set_ncid(ncvar->get_ncfile()->get_ncid());

  status = nc_inq_attid(get_ncid(),get_varid(),get_name().c_str(),&attnum);

  if (status != NC_NOERR) {
    error("Error while quering attribute: %s",nc_strerror(status));
    return;
  }

  set_attnum(attnum);

  read_info();
}
 


octave_ncatt::octave_ncatt(octave_ncfile* ncfilep, int attnump) {
  int status;
  char name[NC_MAX_NAME];
# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new attr " <<  __LINE__ << ":"  << __FUNCTION__ << "attm " << attnump<< std::endl;
# endif

  nca = new ncatt_t;

  set_ncfile(ncfilep);
  set_ncvar(NULL);
  set_attnum(attnump);
  set_varid(NC_GLOBAL);
  set_ncid(get_ncfile()->get_ncid());


  //octave_stdout << "ncid " << ncid << endl;

  status = nc_inq_attname(get_ncid(),get_varid(),get_attnum(),name);

  if (status != NC_NOERR) {
    error("Error while quering attribute: %s",nc_strerror(status));
    return;
  }

  set_name(string(name));
  //octave_stdout << "attname " << attname << endl;

  read_info();
}
   

octave_ncatt::octave_ncatt(octave_ncfile* ncfilep, std::string attnamep) {
  int status, attnum;

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "new attr " <<  __LINE__ << ":"  << __FUNCTION__ << std::endl;
# endif

    nca = new ncatt_t;

   set_ncfile(ncfilep);
   set_ncvar(NULL);
   set_name(attnamep);
   set_varid(NC_GLOBAL);
   set_ncid(get_ncfile()->get_ncid());


   status = nc_inq_attid(get_ncid(),get_varid(),get_name().c_str(),&attnum);

   if (status != NC_NOERR) {
     error("Error while quering attribute: %s",nc_strerror(status));
     return;
   }

   set_attnum(attnum);

   read_info();
 }
 

// ncatt_var(:) = y

octave_value octave_ncatt::subsasgn(const std::string & type,
				const LIST < octave_value_list > &idx,
				const octave_value & rhs)
{
  int status;
  octave_value retval;

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "setting attribute value " << std::endl;
# endif

  if (type[0] != '(' || !idx.front()(0).is_magic_colon() ) {
    error("A ncatt can only be referenced with a (:)");
    return octave_value();
  }

  get_ncfile()->set_mode(DefineMode);

  ov_nc_put_att(get_ncid(),get_varid(),get_name(),get_nctype(),rhs);

  retval = octave_value(this, count + 1);

  return retval;


};

// ncatt_var(:) 

octave_value octave_ncatt::subsref(const std::string SUBSREF_STRREF type,
			       const LIST < octave_value_list > &idx)
{
  int dimid, status, varid;
  size_t length;
  octave_value retval;

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "getting attribute value " << std::endl;
# endif

  if (type[0] != '(' || !idx.front()(0).is_magic_colon() ) {
    error("A ncatt can only be referenced with a (:)");
    return octave_value();
  }

  retval = ov_nc_get_att(get_ncid(),get_varid(),get_name());

  return retval.next_subsref(type, idx);
}


  void octave_ncatt::read_info() {
  size_t length;
  int status;
  nc_type nctype;

  status = nc_inq_att(get_ncid(),get_varid(),get_name().c_str(),&nctype,&length);
  set_nctype(nctype);


  if (status != NC_NOERR) {
    error("Error while quering attribute: %s",nc_strerror(status));
    return;
  }

  nca->dimvec.resize(1);
  nca->dimvec(0) = length;
  }


  void octave_ncatt::print(std::ostream & os, bool pr_as_read_syntax) const {
    os << "attname = " << get_name() << endl;;
    os << "type = " << nctype2ncname(get_nctype()) << endl;;
#   ifdef OV_NETCDF_VERBOSE
    os << "attnum = " << get_attnum() << endl;;
#   endif
  }



DEFINE_OCTAVE_ALLOCATOR(octave_ncatt);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(octave_ncatt, "ncatt", "ncatt");


