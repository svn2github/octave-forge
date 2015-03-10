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


#if !defined (octave_ncfile_int_h)
#define octave_ncfile_int_h 1

#include "ov-netcdf.h"

typedef struct {
  int ncid;
  std::string filename;
  int natts, nvars, unlimdimid, ndims;
  Modes mode;
  int count;
}  ncfile_t ;

class octave_ncfile:public octave_base_value
{
public:
  octave_ncfile(void):octave_base_value(), nf(NULL) {}

  octave_ncfile(const octave_ncfile& ncfile_val):octave_base_value(), nf(ncfile_val.nf) { 
     nf->count++;  
#    ifdef OV_NETCDF_VERBOSE
     octave_stdout << "copy ncfile" << nf << endl;
#    endif
  }

  octave_ncfile(string filenamep, string open_mode, string format="classic");

  OV_REP_TYPE *clone(void) const { return new octave_ncfile(*this); }
  //OV_REP_TYPE *clone(void) const { return (octave_base_value*)this; }

// x.v = y     x(idx).v = y     x{idx}.v = y

  octave_value subsasgn(const std::string & type,
			const std::list < octave_value_list > &idx,
			const octave_value & rhs);

  // x.v     x(idx).v     x{idx}.v

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

  octave_idx_type numel (const octave_value_list&) { return 1; };

  ~octave_ncfile();

  void close();

  void sync();

  void read_info();

  int get_ncid() const { return nf->ncid; }
  int get_nvars() const { return nf->nvars; }
  int get_natts() const { return nf->natts; }
  int get_ndims() const { return nf->ndims; }
  std::string get_filename() const { return nf->filename; }
  Modes get_mode() const  { return nf->mode; }

  void set_mode(Modes new_mode);

  void print(std::ostream & os, bool pr_as_read_syntax) const;

  bool is_constant() const
  {
    return true;
  }
  bool is_defined() const
  {
    return true;
  }
  bool is_map() const
  {
    return true;
  }

private:
  ncfile_t* nf;

#ifdef DEFINE_OCTAVE_ALLOCATOR
  DECLARE_OCTAVE_ALLOCATOR 
#endif
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};



// end octave_ncfile


#endif



/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
