/* 
 *    (C) 2006, September, Muthiah Annamalai. <muthiah.annamalai@uta.edu>
 *    An implementation of the 'outer'-product function as specified in the
 *    octave-projects page, at www.octave.org.
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details. 
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */


#include<iostream>
#include<octave/oct.h>
#include<octave/parse.h>
#include<octave/dynamic-ld.h>
#include<octave/oct-map.h>
#include<octave/oct-stream.h>
#include<octave/ov.h>
#include<octave/parse.h>

#include<octave/Matrix.h>
#include<octave/ov-cx-mat.h>
#include<octave/ov-list.h>
#include<octave/ov-base-mat.h>

#include<octave/quit.h>
#include<octave/error.h>

inline static bool is_vector(octave_value arg) 
{
  return ((arg.is_matrix_type() && !arg.is_char_matrix() && 
	   (arg.columns()==1 || arg.rows()==1)) ? true : false);
}

DEFUN_DLD(outer,args,,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{outer_product} =} outer (@var{x},@var{y})\n\
@deftypefnx {Loadable Function} {@var{outer_product} =} outer (@var{x},@var{y},@var{@@f})\n\
@deftypefnx {Loadable Function} {@var{outer_product} =} outer (@var{x},@var{y},@var{\"f\"})\n\
\n\
Returns the outer product of @var{x} and @var{y}. Both @var{x} and @var{y}\n\
must be vectors. @code{outer} returns a @var{m}-by-@var{n} matrix, where\n\
@var{m} is the length of @var{x} and @var{n} is the length of @var{y}.\n\
\n\
If an optional third argument is supplied, it is used to define a function\n\
that is evaluated as @code{@var{f}(@var{x}(@var{i}),@var{y}(@var{j}))} for\n\
the (@var{i}, @var{j})-th element of return matrix. The function can be\n\
defined as a function handle, inline function or string and must accept two\n\
arguments with the second argument being a vector. If a function is not\n\
provided, '*' is used as the default. An example of the use of @code{outer}\n\
is\n\
\n\
@example\n\
outer(@var{[1.0 2.0 3.0]},@var{[2.0 3.0 4.0]},@@gcd)\n\
@end example\n\
\n\
which computes a 3-by-3 matrix with element element being the GCD of the\n\
corresponding x and y elements of the matrix\n\
@end deftypefn")
{
  octave_idx_type m=0, n=0, aLength=0;
  ColumnVector cv[2];
  bool function_present=false;
  octave_function *func=NULL;
  octave_value_list erval;
  const char *func_name=NULL;
  std::string func_n;

  bool is_commutative=false;

  aLength=args.length();

  if(aLength < 2)
    {
      error("Usage: outer(VecX,VecY,opt:function)");
      return erval;
    }

  if(!(is_vector(args(0)) || is_vector(args(1))))
    {
      error("Usage: outer(VecX,VecY,opt:function);\n Invalid argument arg- [1 or 2]Expected Row/Column Vector");
      return erval;
    }

   /*
   * hope to use commutativity of the operators someday
   */
  if(aLength>=3)
    {
      function_present=true;
      is_commutative=false;

      if(args(2).is_function_handle() || args(2).is_inline_function())
	func=args(2).function_value();	
      else if ( args(2).is_string() )
	{
	  func_n = unique_symbol_name ("__outer_fcn_");
	  std::string fname = "function z = ";
	  fname.append (func_n);
	  fname.append ("(x, y) z = ");
	  func=extract_function(args(2),"outer", func_n, fname,
				"(x,y); endfunction");
	}
      else
	{
	  error("3rd Argument need to be a function. See 'help outer' for more details.");
	  return octave_value(-1);
       }

      if (error_state || !func)
	{
          error("Cannot obtain function handle from inline or user-defined or dynamic loading.");
          return octave_value(-1);
	}
       
    }

  cv[0]=ColumnVector(args(0).vector_value());
  cv[1]=ColumnVector(args(1).vector_value());

  m=cv[0].length();
  n=cv[1].length();

  Matrix rmat(m,n);

  if(function_present && func!=NULL)
    {
      octave_value_list ovl;
      ovl(1) = cv[1];
      for(int itr=0;itr<m;itr++)
	{
	  ovl(0)=cv[0].elem(itr);
	  octave_value_list ret = feval(func, ovl);

	  if(error_state)
	    {
	      error("Exception: while evaluating %s\n", func_name);
	      return erval;
	    }

	  ColumnVector cret = ColumnVector (ret(0).vector_value(false, true));
	  for(int icol=0;icol<n;icol++)
	    {
	      OCTAVE_QUIT;
	      rmat.elem(itr,icol)=cret(icol);
	    }
	}
	  
      if(func_n.length() > 0)
	{
	  // We have a string function name. Dealloc temp func
	  clear_function (func_n);
	}
    }
  else
    {
      /* do a simple product */
      rmat=cv[0]*cv[1].transpose();
    }

  return octave_value(rmat);
}
/* Make command:
g++ -fpic outer.cpp -shared -o outer.oct -Wall -ggdb -Wall -Wunused -Wconversion -fno-exceptions -DDEBUG=1  `mkoctfile -p INCFLAGS` 
*/


/*

%!shared a,b
%! a = [1:3]';
%! b = [1:3];
%!assert(outer(a,b),[1,2,3;2,4,6;3,6,9]);
%!test
%! f = @(x,y) x + y;
%! assert(outer(a,b,f),[2,3,4;3,4,5;4,5,6]);
%!test
%! g = inline('x - y');
%! assert(outer(a,b,g),[0,-1,-2;1,0,-1;2,1,0]);
%!function z = h (x,y)
%! z = x * y;
%!assert(outer(a,b,'h'),[1,2,3;2,4,6;3,6,9]);

*/
