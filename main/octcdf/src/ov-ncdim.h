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

#if !defined (octave_ncdim_int_h)
#define octave_ncdim_int_h 1

#include "ov-netcdf.h"

typedef struct {
  octave_ncfile* ncfile;
  std::string dimname;
  bool is_record;
  int dimid;
  size_t length;
  int count;
}  ncdim_t ;


class octave_ncdim:public octave_base_value {
public:
  octave_ncdim(void):octave_base_value(), ncd(NULL) {
#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "constructor NULL " << this << endl;
#   endif
  } 

  octave_ncdim(const octave_ncdim& ncdim_val):octave_base_value(), ncd(ncdim_val.ncd) { 
    ncd->count++;  
#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "copy ncdim " << ncd << endl;
#   endif
  }

  octave_ncdim(octave_ncfile* ncfile, int dimid);

  OV_REP_TYPE *clone(void) const { return new octave_ncdim(*this); }

  //   octave_value subsasgn(const std::string & type,
  // 			const std::list < octave_value_list > &idx,
  // 			const octave_value & rhs);

  octave_value subsref(const std::string & type,
		       const std::list < octave_value_list > &idx);

  octave_value_list subsref (const std::string& type,
			     const std::list<octave_value_list>& idx, int)
    { return subsref (type, idx); }

  octave_value_list do_multi_index_op(int, const octave_value_list &)
  {
    error("octave_object: do_multi_index_op(nargout,args)");
    return octave_value_list();
  }

  ~octave_ncdim() { 
#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "destruct ncdim " << ncd  << "-" << this << endl;
#   endif

    if (!ncd) {
      // nothing to do
#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "ncd already NULL " << ncd  << endl;
#     endif
      return;
    }

    ncd->count--;

    if (ncd->count == 0) {
#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "delete octave_ncdim: " << ncd << endl;
#     endif
      delete ncd->ncfile;
      delete ncd;
      ncd = NULL;
    }
  }
 
  void read_info();

  /* Query Interface for octave */

  int ndims() const  { return 1; }

  octave_idx_type numel() const  { return  ncd->length; }
  octave_idx_type numel(const octave_value_list&) {  return  ncd->length; };

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
  void set_ncfile(const octave_ncfile* t)  { ncd->ncfile = new octave_ncfile(*t); };
  void set_dimid(const int& t)  { ncd->dimid = t; };
  void set_length(const size_t& t)  { ncd->length = t; };
  void set_record(bool t){ ncd->is_record = t; };

  void rename(string new_name);
private:
  ncdim_t* ncd;

#ifdef DEFINE_OCTAVE_ALLOCATOR
  DECLARE_OCTAVE_ALLOCATOR 
#endif
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};


// end octave_ncdim


#endif



/*
  ;;; Local Variables: ***
  ;;; mode: C++ ***
  ;;; End: ***
*/
