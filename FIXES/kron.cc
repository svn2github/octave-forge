// This program is in the public domain.

#include <octave/oct.h>

#if !defined( CXX_NEW_FRIEND_TEMPLATE_DECL)
extern void
kron(const Array2<double>&a, const Array2<double>&b, Array2<double>&c);
extern void
kron(const Array2<Complex>&a, const Array2<Complex>&b, Array2<Complex>&c);
#endif

template <class T>
void
kron (const Array2<T>&A, const Array2<T>&B, Array2<T>&C)
{
    C.resize(A.rows()*B.rows(),A.columns()*B.columns());
    int Ar,Ac,Cr,Cc;

    for (Ac = Cc = 0; Ac < A.columns(); Ac++, Cc += B.columns())
      for (Ar = Cr = 0; Ar < A.rows(); Ar++, Cr += B.rows())
	{
	  const T v = A (Ar, Ac);
	  for (int Bc=0; Bc < B.columns(); Bc++)
	    for (int Br=0; Br < B.rows(); Br++)
	      C.xelem(Cr+Br,Cc+Bc) = v*B.elem(Br,Bc);
	}
}

template void
kron(const Array2<double>&a, const Array2<double>&b, Array2<double>&c);
template void
kron(const Array2<Complex>&a, const Array2<Complex>&b, Array2<Complex>&c);

DEFUN_DLD(kron, args,  nargout, "-*- texinfo -*-\n\
@deftypefn {Function File} {} kron (@var{a}, @var{b})\n\
Form the kronecker product of two matrices, defined block by block as\n\
\n\
@example\n\
x = [a(i, j) b]\n\
@end example\n\
\n\
For example,\n\
\n\
@example\n\
@group\n\
kron (1:4, ones (3, 1))\n\
      @result{}  1  2  3  4\n\
          1  2  3  4\n\
          1  2  3  4\n\
@end group\n\
@end example\n\
@end deftypefn")
{
    octave_value_list retval;
    int nargin = args.length();

    if (nargin != 2 || nargout > 1)
    {
	print_usage("kron");
    }
    else if (args(0).is_complex_type() || args(1).is_complex_type())
    {
	ComplexMatrix a (args(0).complex_matrix_value());
	ComplexMatrix b (args(1).complex_matrix_value());
	if (! error_state)
	{
	    ComplexMatrix c;
	    kron (a, b, c);
	    retval (0) = c;
	}
    }
    else
    {
	Matrix a (args(0).matrix_value());
	Matrix b (args(1).matrix_value());
	if (! error_state)
	{
	    Matrix c;
	    kron (a, b, c);
	    retval (0) = c;
	}
    }
    return retval;
}

