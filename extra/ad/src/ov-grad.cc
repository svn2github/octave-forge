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

#include "ov-grad.h"
#include <octave/defun-dld.h>
#include <octave/ov-re-sparse.h>
#include <octave/utils.h>
#include <variables.h>
#include <octave/ls-oct-ascii.h>
#include <octave/ls-oct-binary.h>

#define GRAD_X_STR "x"
#define GRAD_J_STR "J"
#define GRAD_DX_STR "dx"

DEFINE_OCTAVE_ALLOCATOR (octave_gradient);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_gradient, "gradient", "gradient");

/*  static class variables */
bool octave_gradient::use_sparse_jacobian = false;
octave_idx_type octave_gradient::num_derivatives = 1;

static inline
octave_value zero_mx (octave_idx_type r, octave_idx_type c)
{
	return octave_gradient::sparse_storage_mode () ? 
		octave_value (SparseMatrix (r, c, 0)) :
		octave_value (NDArray (dim_vector (r, c), 0.0));
}

static inline
octave_value eye_mx (octave_idx_type n)
{
  if (octave_gradient::sparse_storage_mode ())
    {
      idx_vector ix (0, n-1);
      return SparseMatrix (ColumnVector (1, 1.0), ix, ix, n, n, false);
    }
  else
    return identity_matrix (n, n);
}

/* constructor & member functions */
octave_gradient::octave_gradient (const octave_value& v, init_type t) 
	: xval(v)
{
	dval = (t == dependent) ? 
		eye_mx (num_derivatives = v.dims ().numel ()) : 
	    zero_mx (num_derivatives, v.dims ().numel ());
}

octave_value octave_gradient::jacobian () const
{
	return ::op_transpose (dval);
}

void octave_gradient::print (std::ostream& os, bool pr_as_read_syntax) const 
{
	x ().print_with_name (os, "value");
	// print (partial) derivative(s),
	// following convention i-th row = nabla(x_i)T
	jacobian ().print_with_name (os, "(partial) derivative(s)");
}

octave_value_list octave_gradient::dotref (const octave_value_list& idx) 
{
	octave_value_list retval;
	std::string nm = idx(0).string_value ();
	if (nm == GRAD_X_STR) 
		retval(0) = x ();
	else if (nm == GRAD_J_STR)
		retval(0) = jacobian ();
	else if (nm == GRAD_DX_STR)
		retval(0) = dx ();
	else error ("gradient structure has no member `%s'", nm.c_str ());
	return retval;
}

octave_value octave_gradient::subsref (const std::string& type, const std::list<octave_value_list>& idx) 
{
	octave_value retval;
	switch (type[0]) 
	{
		case '(':
			retval = do_index_op (idx.front (), true);
			break;
		case '.': 
		{
 			octave_value_list t = dotref (idx.front());
 			retval = (t.length () == 1) ? t(0) : octave_value (t);
			break;
		}
		default:
			error ("%s cannot be indexed with %c", type_name ().c_str (), type[0]);
	}
	if (!error_state)
		retval = retval.next_subsref (type, idx, 1);
	return retval;
}

octave_value octave_gradient::subsasgn (
			 const std::string& type,
			 const std::list<octave_value_list>& idx,
			 const octave_value& rhs)
{
	octave_value retval;
	switch (type[0])
	{
		case '(':
		{
			// we probably don't need this, but who knows?
			// verbatim copy from octave_base_value::subsasgn

			if (type.length () == 1)
				retval = numeric_assign (type, idx, rhs);
			else if (is_empty ())
			{
				octave_value tmp = octave_value::empty_conv (type, rhs);
				retval = tmp.subsasgn (type, idx, rhs);
			}
			else
			{
				std::string nm = type_name ();
				error ("in indexed assignment of %s, last rhs index must be ()", nm.c_str ());
			}
			break;
		}
		
		// here is the case of interest: make it possible to access members from outside
		// pro: we can write more transparent and easily maintainable .m files for
		// mappers instead of DLD functions
		// con: loss of privacy. Who is to guarantee consistency of state
		// when members can be assigned arbitrary values?

		case '.':
		{
			std::string s = idx.front ()(0).string_value ();
			if (s == GRAD_X_STR)
			{
				if ((type.length () == 2) && (type[1] == '('))
				{
					std::list<octave_value_list> new_idx (idx);
					new_idx.erase (new_idx.begin ());
					xval = xval.assign (octave_value::op_asn_eq, "(", new_idx, rhs);
				}
				else xval = rhs;
				return new octave_gradient (*this);
			}
			if (s == GRAD_DX_STR)
			{
				if ((type.length () == 2) && (type[1] == '('))
				{
					std::list<octave_value_list> new_idx (idx);
					new_idx.erase (new_idx.begin ());
					dval = dval.assign (octave_value::op_asn_eq, "(", new_idx, rhs);
				}
				else dval = rhs;
				return new octave_gradient (*this);
			}
			if (s == GRAD_J_STR)
				 error ("jacobian cannot be assigned to directly");
			else error ("gradient structure has no member %s", s.c_str ());
			break;
		}
	}
	return retval;
}

// returns an index-vector, obtained by translating each n-dimensional index 
// (i_1, i_2, ..., i_n) in the cartesian product idx(1) x idx(2) x ... x idx(n) 
// to a linear 1d index, assuming an object of size dv.
// by the time we call, idx has already been asserted to hold valid indices

static 
octave_value xlate_indices (const octave_value_list& idx, const dim_vector& dv)
{
	if (idx.length () > 1)
	{
		bool b = true;
		octave_idx_type k, l, p;
		l = p = 1;
		for (k = 0; k < idx.length (); k++)
		{
			if (idx(k).is_empty ()) 
				return NDArray (dim_vector (1, 0));
			b &= idx(k).is_magic_colon ();
			l *= idx(k).is_magic_colon () ? dv(k) : idx(k).length ();
			p *= dv(k);
		}
		if (b) return octave_value::magic_colon_t;

		octave_idx_type c, i, j, t, v;
		NDArray vec = NDArray (dim_vector (1, l), 1.0);

		t = 1;
		for (k = k - 1; k >= 0; k--)
		{
			c = 0;
			p /= dv(k);
			if (!idx(k).is_magic_colon ())
			{
				l /= (v = idx(k).length ());
				t *= v;
				const idx_vector& iv = idx(k).index_vector ();
				for (i = 0; i < t; i++)
					for (j = 0; j < l; j++)
						vec(c++) += iv(i % v) * p;
			}
			else
			{
				l /= (v = dv(k));
				t *= v;
				for (i = 0; i < t; i++)
					for (j = 0; j < l; j++)
						vec(c++) += (i % v) * p;
			}
		}
		return vec;
	}
	return idx(0);
}

octave_value octave_gradient::do_index_op (const octave_value_list& idx, bool resize_ok)
{
	// octave will resize array instead of throwing index-out-of-bounds error 
	// when I forward resize_ok here, so I mustn't.
	// (still don't quite understand why...)

	const octave_value& tmp = xval.do_index_op (idx);
	if (!error_state)
	{
		octave_value_list idx_dval (2, octave_value::magic_colon_t);
		idx_dval(1) = xlate_indices (idx, dims ());
		if (idx_dval(1).is_empty ())
			return tmp;
		const octave_value& aux = dval.do_index_op (idx_dval);
		return (aux.is_sparse_type () && aux.nnz () == 0) ?
			tmp : new octave_gradient (tmp, aux);
	}
	return octave_value ();
}

// assignement from dependent term
void octave_gradient::assign (const octave_value_list& idx, const octave_gradient& rhs)
{
	std::list<octave_value_list> lst;
	lst.push_back (idx);
	xval = xval.assign (octave_value::op_asn_eq, "(", lst, rhs.x ());

	if (!error_state)
	{
		const dim_vector& dv1 = dx ().dims ();
		const dim_vector& dv2 = rhs.dx ().dims ();

		if (dv1(0) == dv2(0))
		{
			octave_idx_type nc;
			octave_idx_type n = numel ();
			if (n != dv1(1))
				dval = dval.resize (dim_vector (dv1(0), n), true);

			octave_value_list idx_dval = 
				octave_value (octave_value::magic_colon_t);
			idx_dval.append (xlate_indices (idx, dims ()));

			lst.pop_back ();
			lst.push_back (idx_dval);

			// assignment of scalar to non-scalar works fine, but not
			// the generalization (n-1) to n-dimensional object for n>1, so we 
			// have to take care of that, too. Otherwise
			// a = gradinit([1,2]); a(1:5) = a(1) will not work

			if (dv2(0) > 1 && (nc = idx_dval(1).is_magic_colon () ? n : idx_dval(1).length ()) > dv2(1))
			{
				octave_value_list tmp = 
					octave_value (octave_value::magic_colon_t);
				tmp.append (NDArray (dim_vector (1, nc), 1.0));
				dval = dval.assign (octave_value::op_asn_eq, "(", lst, octave_value (rhs.dx ()).do_index_op (tmp));
			}
			else dval = dval.assign (octave_value::op_asn_eq, "(", lst, rhs.dx ());
		}
		else error ("AD assign: operands differ in number of derivatives");
	}
}

// assignement from constant term
void octave_gradient::assign_const (const octave_value_list& idx, const octave_value& rhs)
{
	std::list<octave_value_list> lst;
	lst.push_back (idx);
	xval = xval.assign (octave_value::op_asn_eq, "(", lst, rhs);

	if (!error_state)
	{
		octave_value_list idx_dval = 
			octave_value (octave_value::magic_colon_t);
		idx_dval.append (xlate_indices (idx, dims ()));

		lst.pop_back ();
		lst.push_back (idx_dval);

		if (!rhs.is_empty ())
		{
			const dim_vector& dv = dx ().dims ();
			octave_idx_type n = numel ();
			if (n != dv(1)) 
				dval = dval.resize (dim_vector (dv(0), n), true);
			dval = dval.assign (octave_value::op_asn_eq, "(", lst, 0.0);
		}
		else
			dval = dval.assign (octave_value::op_asn_eq, "(", lst, rhs);
	}
}

octave_value octave_gradient::resize (const dim_vector& dv, bool fill) const
{
	const dim_vector& current_dims = dims ();
	octave_idx_type l = dv.length () < current_dims.length () ? 
					    dv.length () : current_dims.length ();

	octave_value_list tmp (l, octave_value::magic_colon_t);
	for (octave_idx_type k = 0; k < l; k++)
		if (current_dims(k) != dv(k)) 
			tmp(k) = Range (1.0, current_dims(k) < dv(k) ? current_dims(k) : dv(k));

	octave_value_list idx_lhs (2, octave_value::magic_colon_t);
	octave_value_list idx_rhs (2, octave_value::magic_colon_t);
	idx_lhs(1) = xlate_indices (tmp, dv);
	idx_rhs(1) = xlate_indices (tmp, current_dims);

	std::list<octave_value_list> lst;
	lst.push_back (idx_lhs);

	octave_value new_dval = zero_mx (nderv (), dv.numel ());

	new_dval = new_dval.assign (octave_value::op_asn_eq, 
		"(", lst, octave_value (dval).do_index_op (idx_rhs));
	return new octave_gradient (xval.resize (dv, fill), new_dval);
}

static inline void gripe_no_rule ()
{
	error ("AD-rule unknown or function not overloaded");
}

double octave_gradient::double_value (bool) const
{
	gripe_no_rule ();
	return double ();
}

double octave_gradient::scalar_value (bool) const
{
	gripe_no_rule ();
	return double ();
}

NDArray octave_gradient::array_value (bool) const
{
	gripe_no_rule ();
	return NDArray ();
}

octave_value octave_gradient::convert_to_str_internal (bool, bool, char) const
{
	gripe_no_rule ();
	return octave_value ();
}

// io methods
bool octave_gradient::save_ascii (std::ostream& os)
{
	return (save_ascii_data (os, xval, GRAD_X_STR, 
				false, os.precision ()) && 
		    save_ascii_data (os, dval, GRAD_J_STR, 
				false, os.precision ()));
}

bool octave_gradient::load_ascii (std::istream& is)
{
	bool global;
	return ((read_ascii_data (is, std::string (), 
				global, xval, 0) == GRAD_X_STR) &&
		    (read_ascii_data (is, std::string (), 
				global, dval, 0) == GRAD_J_STR));
}

bool octave_gradient::save_binary (std::ostream& os, bool& save_as_floats)
{
  	return (save_binary_data (os, xval, GRAD_X_STR, std::string (),
				false, save_as_floats) &&
		    save_binary_data (os, dval, GRAD_J_STR, std::string (), 
				false, save_as_floats));
}

bool octave_gradient::load_binary (std::istream& is, bool swap, oct_mach_info::float_format fmt)
{
	bool global;
	std::string doc;
	return ((read_binary_data (is, swap, fmt, std::string (), global, xval, doc)
				== GRAD_X_STR) && 
		    (read_binary_data( is, swap, fmt, std::string (), global, dval, doc)
				== GRAD_J_STR));
}

void install_gradient_ops (void);
DEFUN_DLD (gradinit, args, nargout,
"-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{g} =} gradinit (@var{x})\n"
"Create a gradient with value @var{x} and derivative @code{eye}(@code{numel}(@var{x}))\n"
"\n"
"Substituting @var{x} -> @var{g} in an analytical expression @var{F}\n"
"depending on @var{x} will then produce at once @var{F}(@var{x}) and\n"
"the jacobian @math{D}@var{F}(@var{x}). See example below:\n"
"\n"
"@example\n"
"@group\n"
"a = gradinit ([1; 2]);\n"
"b = [a.' * a; 2 * a]\n"
"@result{}\n"
"b =\n"
"\n"
"value =\n"
"\n"
"  5\n"
"  2\n"
"  4\n"
"\n"
"(partial) derivative(s) =\n"
"\n"
"  2  4\n"
"  2  0\n"
"  0  2\n"
"\n"
"@end group\n"
"@end example\n"
"\n"
"Members can be accessed by suffixing the variable with .x and .J\n"
"respectively\n"
"@end deftypefn\n"
"@seealso{use_sparse_jacobians}"
)
{
	octave_value_list retval;
	static bool type_loaded = false;
	if (!type_loaded)
	{
		octave_gradient::register_type ();
		install_gradient_ops ();
		type_loaded = true;
	}

	int nargin = args.length ();
	if ((nargin == 1) && (nargout < 2))
	{
		const octave_value& arg = args(0);
		if (arg.is_numeric_type () && 
		   (arg.type_id () != octave_gradient::static_type_id ()))
			retval(0) = new octave_gradient (arg);
		else error ("invalid type");
	}
	else print_usage ();
	return retval;
}

// PKG_ADD: autoload ("isgradient", "gradinit.oct");
DEFUN_DLD (isgradient, args, nargout,
"-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} isgradient (@var{x})\n"
"Return 1 if @var{x} is a gradient, otherwise return 0\n"
"@end deftypefn\n")
{
	octave_value_list retval;
	if (args.length () == 1)
		retval(0) = (args(0).type_id () == octave_gradient::static_type_id ());
	else print_usage ();
	return retval;
}

// PKG_ADD: autoload ("use_sparse_jacobians", "gradinit.oct");
DEFUN_DLD (use_sparse_jacobians, args, nargout,
"-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{val} =} use_sparse_jacobians ()\n"
"@deftypefnx {Loadable Function} {@var{val} =} use_sparse_jacobians (@var{new_val})\n"
"Query or set the storage mode for AD. If nonzero, gradients\n"
"will try to store partial derivatives as a sparse matrix\n"
"@end deftypefn")
{
	octave_value_list retval;
	bool Vuse_sparse_jacobians = octave_gradient::sparse_storage_mode ();
	retval = SET_INTERNAL_VARIABLE(use_sparse_jacobians);

	octave_gradient::set_storage_mode (
		Vuse_sparse_jacobians ? octave_gradient::sparse : octave_gradient::dense);
	return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
