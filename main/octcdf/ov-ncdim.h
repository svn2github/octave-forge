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

#if !defined (octave_ncdim_int_h)
#define octave_ncdim_int_h 1

#include "ov-netcdf.h"

typedef struct {
  octave_ncfile* ncfile;
  std::string dimname;
  bool is_record;
  int dimid;
  size_t length;
}  ncdim_t ;


class octave_ncdim:public octave_base_value {
public:
   octave_ncdim(void):octave_base_value(), ncd(NULL) { } 

  octave_ncdim(const octave_ncdim& ncdim_val):octave_base_value(), ncd(ncdim_val.ncd) { }

  octave_ncdim(octave_ncfile* ncfile, int dimid);

  octave_value *clone(void) const { return new octave_ncdim(*this); }

//   octave_value subsasgn(const std::string & type,
// 			const LIST < octave_value_list > &idx,
// 			const octave_value & rhs);

  octave_value subsref(const std::string SUBSREF_STRREF type,
		       const LIST < octave_value_list > &idx);

  octave_value_list do_multi_index_op(int, const octave_value_list &)
  {
    error("octave_object: do_multi_index_op(nargout,args)");
    return octave_value_list();
  }

  ~octave_ncdim()  { 
#  ifdef OV_NETCDF_VERBOSE
    octave_stdout << "destruct " << std::endl;  
#  endif
  }
 
  void read_info();

  /* Query Interface for octave */

  int ndims() const  { return 1; }

  int numel() const  { return  ncd->length; }

  dim_vector dims() const {  return dim_vector(ncd->length,1); }


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


  std::string get_name() const { return ncd->dimname; };
  octave_ncfile* get_ncfile() const { return ncd->ncfile; };
  int get_dimid() const { return ncd->dimid; };
  size_t get_length() const { return ncd->length; };
  bool is_record() const { return ncd->is_record; };
  int get_ncid() const { return ncd->ncfile->get_ncid(); };

  void set_name(const std::string& t) { ncd->dimname = t; };
  void set_ncfile(octave_ncfile* t)  { ncd->ncfile = t; };
  void set_dimid(const int& t)  { ncd->dimid = t; };
  void set_length(const size_t& t)  { ncd->length = t; };
  void set_record(bool t){ ncd->is_record = t; };

private:
  ncdim_t* ncd;


  DECLARE_OCTAVE_ALLOCATOR 
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};


// end octave_ncdim


#endif



/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
