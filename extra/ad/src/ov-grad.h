/*
Copyright (C) 2006, 2007 Thomas Kasper, <thomaskasper@gmx.net>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>. 
*/

# if !defined(grad_h)
#define grad_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <octave/config.h>
#include <octave/ov-base.h>
#include <octave/ov.h>
#include <octave/ov-scalar.h>

class octave_value_list;

class octave_gradient : public octave_base_value 
{
public:
	enum init_type {
		constant, dependent
	};

	octave_gradient (void)
		: xval (octave_value ()),
		  dval (NDArray (dim_vector (num_derivatives, 0))) {}

	octave_gradient (const octave_value& v, init_type t = dependent);
	octave_gradient (const octave_gradient& g)
		: xval (g.xval), dval (g.dval) {}

	~octave_gradient (void) {}

	octave_base_value * clone (void) const 
		{ return new octave_gradient (*this); }

	octave_base_value * empty_clone (void) const
		{ return new octave_gradient (); }

	size_t byte_size (void) const 
		{ return xval.byte_size () + dval.byte_size (); }

	void print (std::ostream& os, bool pr_as_read_syntax = false) const;
	octave_value_list dotref (const octave_value_list& idx);
	octave_value subsref (const std::string& type, const std::list<octave_value_list>& idx);

	octave_value_list subsref (const std::string& type,
				   const std::list<octave_value_list>& idx, int)
	  { return subsref (type, idx); }

	octave_value subsasgn (const std::string& type, const std::list<octave_value_list>& idx, const octave_value& rhs);
	octave_value do_index_op (const octave_value_list& idx, bool resize_ok);
	octave_value resize (const dim_vector& dv, bool fill = 0) const;
	octave_value reshape (const dim_vector& dv) const
	  {  return new octave_gradient (x ().reshape (dv), dx ()); }

	/* assignment from dependent term (=gradient) */
	void assign (const octave_value_list& idx, const octave_gradient& rhs);
	
	/* assignment from non-dependent term */
	template<class T> inline void assign (const octave_value_list& idx, const T& rhs)
		{ assign_const (idx, rhs.clone ()); }

	bool is_matrix_type (void) const { return xval.is_matrix_type (); }
	bool is_scalar_type (void) const { return xval.is_scalar_type (); }
	bool is_real_type (void) const { return xval.is_real_type (); }
	bool is_complex_type (void) const { return xval.is_complex_type (); }
	bool is_sparse_type (void) const { return xval.is_sparse_type (); }
	bool is_defined (void) const { return true; }
	bool is_numeric_type (void) const { return true; }
	bool is_constant (void) const { return true; }
	bool is_map (void) const { return true; }
	dim_vector dims (void) const { return xval.dims (); }

	MatrixType matrix_type (void) const { return xval.matrix_type (); }
	MatrixType matrix_type (const MatrixType& typ) const { return xval.matrix_type (); }
	
	inline octave_idx_type nderv (void) const { return dval.rows (); }
	inline const octave_value& x () const { return xval; }
	inline const octave_value& dx () const { return dval; }
	octave_value jacobian () const;

	// differentiation makes no sense here
	// behave like the corresponding non-AD-type
	idx_vector index_vector (void) const { return xval.index_vector (); }
	octave_value all (int dim = 0) const { return xval.all (dim); }
	octave_value any (int dim = 0) const { return xval.any (dim); }

	double double_value (bool frc_str_conv) const;
	double scalar_value (bool frc_str_conv) const;
	NDArray array_value (bool frc_str_conv = false) const;
	octave_value convert_to_str_internal (bool pad, bool force, char type) const;

	enum storage_mode {
		dense  = 0,
		sparse = 1
	};

	static inline bool sparse_storage_mode ()
	{ // query preferred storage mode for jacobian
		return use_sparse_jacobian; 
	}
	static inline void set_storage_mode (storage_mode val)
	{ // set preferred storage mode for jacobian
		use_sparse_jacobian = static_cast<bool>(val); 
	}
	
	// io methods
	bool save_ascii (std::ostream& os);
	bool load_ascii (std::istream& is);
	bool save_binary (std::ostream& os, bool& save_as_floats);
	bool load_binary (std::istream& is, bool swap, oct_mach_info::float_format fmt);

	// should be protected, but I don't care to list all ops as friends
	octave_gradient (const octave_value& xv, const octave_value& dv) : xval (xv), dval (dv) {}

private:
	void assign_const (const octave_value_list& idx, const octave_value& rhs);
	
	/* these may be anything: scalar or matrix, complex or real, sparse or dense,
	 so let's be vague about it: */
	octave_value xval;
	octave_value dval;

	static octave_idx_type num_derivatives;
	static bool use_sparse_jacobian;

	DECLARE_OCTAVE_ALLOCATOR
	DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif
