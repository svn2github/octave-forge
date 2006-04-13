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

#if !defined (octave_ncatt_int_h)
#define octave_ncatt_int_h 1

#include "ov-netcdf.h"

#ifndef OV_REP_TYPE
#define OV_REP_TYPE octave_value
#endif

typedef struct {
  nc_type nctype;
  dim_vector dimvec;
  octave_ncfile* ncfile;
  octave_ncvar* ncvar;
  std::string attname;
  int ncid,varid,attnum;
}  ncatt_t ;


class octave_ncatt:public octave_base_value {
public:
  octave_ncatt(void):octave_base_value(), nca(NULL) { } 

  octave_ncatt(const octave_ncatt& ncatt_val):octave_base_value(), nca(ncatt_val.nca) { }

  octave_ncatt(octave_ncvar* ncvarp, int attnump); 
  octave_ncatt(octave_ncvar* ncvarp, std::string attnamep); 
  octave_ncatt(octave_ncfile* ncvarp, int attnump);
  octave_ncatt(octave_ncfile* ncvarp, std::string attnamep);

  OV_REP_TYPE *clone(void) const { return new octave_ncatt(*this); }

  octave_value subsasgn(const std::string & type,
			const LIST < octave_value_list > &idx,
			const octave_value & rhs);

  octave_value subsref(const std::string SUBSREF_STRREF type,
		       const LIST < octave_value_list > &idx);

  octave_value_list do_multi_index_op(int, const octave_value_list &)
  {
    error("octave_object: do_multi_index_op(nargout,args)");
    return octave_value_list();
  }

  ~octave_ncatt()  { }
 
  void read_info();

  /* Query Interface for octave */

  int ndims() const  { return dims().length(); }

  octave_idx_type numel() const  { return dims().numel(); }

  dim_vector dims() const {  return nca->dimvec; }

  void print(std::ostream & os, bool pr_as_read_syntax) const;

  bool is_constant(void) const  {
    return true;
  }
  bool is_defined(void) const  {
    return true;
  }
  bool is_map(void) const  {
    return true;
  }


  nc_type get_nctype(void) const { return nca->nctype; };
  std::string get_name() const { return nca->attname; };
  octave_ncfile* get_ncfile() const { return nca->ncfile; };
  octave_ncvar*  get_ncvar() const { return nca->ncvar; };
  int get_ncid() const { return nca->ncid; };
  int get_varid() const { return nca->varid; };
  int get_attnum() const { return nca->attnum; };

  void set_nctype(const nc_type& t)  { nca->nctype = t; } ;
  void set_name(const std::string& t) { nca->attname = t; };
  void set_ncfile(octave_ncfile* t)  { nca->ncfile = t; };
  void set_ncvar(octave_ncvar* t)  { nca->ncvar = t; };
  void set_ncid(const int& t)  { nca->ncid = t; };
  void set_varid(const int& t)  { nca->varid = t; };
  void set_attnum(const int& t)  { nca->attnum = t; };

  void rename(string new_name);

private:
  ncatt_t* nca;


  DECLARE_OCTAVE_ALLOCATOR 
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};


// end octave_ncatt


#endif



/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
