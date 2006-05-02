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

#if !defined (octave_ncvar_int_h)
#define octave_ncvar_int_h 1

#include "ov-netcdf.h"

typedef struct {
  std::list<std::string> dimnames;
  int dimids[NC_MAX_VAR_DIMS];

  //std::list <std::string> dimnames;
  nc_type nctype;
  int ncid;

  // Octave-like dim_vector. A scale would have a dimension of 1x1
  dim_vector dimvec;

  // NetCDF-like dim_vector. A scale would have a dimension of 0
  dim_vector ncdimvec;

  int varid, natts;
  octave_ncfile* ncfile;
  std::string varname;
  bool autoscale;
  bool autonan;

}  ncvar_t ;

class octave_ncvar:public octave_base_value {
public:
  octave_ncvar(void):octave_base_value(), ncv(NULL) {}

  octave_ncvar(const octave_ncvar& nc_val):octave_base_value(), ncv(nc_val.ncv) { }

  octave_ncvar(octave_ncfile* ncfilep, int varid);
   
  octave_ncvar(octave_ncfile* ncfilep, std::string varnamep);

  octave_ncvar(nc_type nctypep, std::list <std::string> dimnamesp):octave_base_value(), ncv(NULL) { }

  OV_REP_TYPE *clone(void) const { return new octave_ncvar(*this); }

// x.v = y     x(idx).v = y     x{idx}.v = y

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

  ~octave_ncvar()  { }
 
  void read_info();

  /* Query Interface for octave */

  // Get dim_vector following Octave conventions

  dim_vector dims() const {  return ncv->dimvec; }

  int ndims() const  { return dims().length(); }

  octave_idx_type numel() const  { return dims().numel(); }

  // Get dim_vector following NetCDF conventions

  dim_vector ncdims() const {  return ncv->ncdimvec; }

  int ncndims() const  { return ncdims().length(); }


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

  bool& autoscale() { return ncv->autoscale; };
  bool autoscale() const { return ncv->autoscale; };

  bool& autonan() { return ncv->autonan; };
  bool autonan() const { return ncv->autonan; };

  /* Query Interface for netcdf related information */

  std::list<Range> get_slice(octave_value_list key_idx);

  nc_type get_nctype(void) const { return ncv->nctype; };
  octave_ncfile* get_ncfile() const { return ncv->ncfile; };
  int get_varid() const { return ncv->varid; };
  int get_ncid() const { return ncv->ncid; };
  int get_natts() const { return ncv->natts; };
  std::string get_varname() const { return ncv->varname; };
  int get_dimid(int i) const { return ncv->dimids[i]; };
  std::list<std::string> get_dimnames() const { return ncv->dimnames; };


  void set_nctype(const nc_type t) { ncv->nctype = t; };
  void set_ncfile(octave_ncfile* t) { ncv->ncfile = t; };
  void set_varid(const int& t)  { ncv->varid = t; };
  void set_ncid(const int& t)  { ncv->ncid = t; };
  void set_natts(const int& t)  { ncv->natts = t; };
  void set_varname(const std::string& t) { ncv->varname = t; };
  void set_dimid(int i,int t) const { ncv->dimids[i] = t; };
  void set_dimnames(const std::list<std::string> t) { ncv->dimnames = t; };

  void rename(string new_name);

  ncvar_t* ncv;

private:

  DECLARE_OCTAVE_ALLOCATOR 
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};


// end octave_ncvar

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
