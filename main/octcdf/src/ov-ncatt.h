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

#if !defined (octave_ncatt_int_h)
#define octave_ncatt_int_h 1

#include "ov-netcdf.h"

typedef struct {
  nc_type nctype;
  dim_vector dimvec;
  octave_ncfile* ncfile;
  octave_ncvar* ncvar;
  std::string attname;
  int ncid,varid,attnum;
  int count;
}  ncatt_t ;


class octave_ncatt:public octave_base_value {
public:
  octave_ncatt(void):octave_base_value(), nca(NULL) { } 

  octave_ncatt(const octave_ncatt& ncatt_val):octave_base_value(), nca(ncatt_val.nca) { 
    nca->count++;  
#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "copy ncatt " << nca << endl;
#   endif
  }

  octave_ncatt(octave_ncvar* ncvarp, int attnump); 
  octave_ncatt(octave_ncvar* ncvarp, std::string attnamep); 
  octave_ncatt(octave_ncfile* ncvarp, int attnump);
  octave_ncatt(octave_ncfile* ncvarp, std::string attnamep);

  OV_REP_TYPE *clone(void) const { return new octave_ncatt(*this); }

  octave_value subsasgn(const std::string & type,
			const std::list < octave_value_list > &idx,
			const octave_value & rhs);

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

  ~octave_ncatt()  {
#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "destruct nca " << nca  << endl;
#   endif

    if (!nca) {
      // nothing to do
#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "nca already NULL " << nca  << endl;
#     endif
      return;
    }

    nca->count--;

    if (nca->count == 0) {
#     ifdef OV_NETCDF_VERBOSE
      octave_stdout << "delete octave_nca: " << nca << endl;
#     endif
      delete nca->ncfile;
      if (nca->ncvar) delete nca->ncvar;
      delete nca;
      nca = NULL;
    }
  }
 
  void read_info();

  /* Query Interface for octave */

  int ndims() const  { return dims().length(); }

  octave_idx_type numel() const  { return dims().numel(); }
  octave_idx_type numel(const octave_value_list&) { return 1; };

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
  void set_ncfile(const octave_ncfile* t)  { nca->ncfile = new octave_ncfile(*t); };
  void set_ncvar(const octave_ncvar* t)  { 
    if (t)
      nca->ncvar = new octave_ncvar(*t);
    else 
      nca->ncvar = NULL; 
  };
  void set_ncid(const int& t)  { nca->ncid = t; };
  void set_varid(const int& t)  { nca->varid = t; };
  void set_attnum(const int& t)  { nca->attnum = t; };

  void rename(string new_name);

private:
  ncatt_t* nca;

#ifdef DEFINE_OCTAVE_ALLOCATOR
  DECLARE_OCTAVE_ALLOCATOR 
#endif
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};


// end octave_ncatt


#endif



/*
  ;;; Local Variables: ***
  ;;; mode: C++ ***
  ;;; End: ***
*/
