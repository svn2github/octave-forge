#include <octave/oct.h>
#include <octave/pager.h>
#include <lo-ieee.h>
#include <float.h>
using namespace std;

// Copyright (C) 2000 Ben Sapp.  All rights reserved.
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 2, or (at your option) any
// later version.
//
// This is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.

// 2001-09-20 Paul Kienzle <pkienzle@users.sf.net>
// * Use x((int)rint(m(i,j))) instead of x(m(i,j))

#define TRUE 1
#define FALSE 0

static inline Matrix identity_matrix(int m,int n)
{
  int min = (m > n) ? n : m; 
  Matrix me(m,n,0.0);
  for(int i=0;i<min;i++){
    me(i,i) = 1.0;
  }
  return(me);
}

static inline Matrix identity_matrix(int n)
{
  return(identity_matrix(n,n));
}

// It would be nice if this was a function in the Matrix class
static Matrix pivot(Matrix T, int the_row,int the_col)
{
  int nr = T.rows();
  Matrix Id = identity_matrix(nr);
  Matrix result;
  for(int i=0;i<nr;i++){
    Id(i,the_row) = -T(i,the_col)/T(the_row,the_col);
  }
  Id(the_row,the_row) = 1/T(the_row,the_col);
  //octave_stdout << "After pivot T =\n" << Id*T << "\n";
  result = Id*T;
  for(int j=0;j<nr;j++){
    T(j,the_col) = 0;
  }
  T(the_row,the_col) = 1;
  return(result);
}

// Remove the 
static Matrix multi_pivot(Matrix T,Matrix the_pivots)
{
  if(the_pivots.cols() != 2){
    octave_stdout << "Error in multi_pivot\n";
  }
  int nr = the_pivots.rows();
  for(int i=0;i<nr;i++){
    T = pivot(T,int(the_pivots(i,0)),int(the_pivots(i,1)));
  }
  return(T);
}

#define CASE_A 0 // h_j -> The upper bound is the smallest
#define CASE_B 1 // min{y_i0/y_ij} for all y_ij > 0 is the smallest 
#define CASE_C 2 // min{(y_i0-h_j)/y_ij) for all y_ij < 0 is the smallest
// This takes a tableau and reduces it to the solution tableau.  
static Matrix minimize(Matrix T, Matrix &basis,ColumnVector upper_bounds,RowVector &which_bound)
{
  int nr = T.rows();
  int nc = T.cols();
  int i,j,k,min_case;
  double min_val;
  int min_row = 0;
  int found_one;

  while(TRUE){
    found_one = FALSE;
    for(i=0;i<(nc-1);i++){
      if(T(nr-1,i) < -10.0*DBL_EPSILON){
	found_one = TRUE;
	break;
      }
    }
    if(!found_one){
      break;
    }
    // Now i is the column we will pivot on.  
    min_row = -1;
    min_case = CASE_A;
    min_val = upper_bounds(i);
    for(j=0;j<(nr-1);j++){
      if(T(j,i) > 0){
	if(min_val > (T(j,nc-1)/T(j,i))){
	  min_row = j;
	  min_val = T(j,nc-1)/T(j,i);
	  min_case = CASE_B;
	}
      }else if(T(j,i) < 0){
	if(min_val > ((T(j,nc-1)-upper_bounds(i))/T(j,i))){
	  min_row = j;
	  min_val = (T(j,nc-1)-upper_bounds(i))/T(j,i);
	  min_case = CASE_C;
	}
      }
    }
    
    int interesting_column=0;
    for(j=0;j<(nr-1);j++){
      if(basis(j,0) == min_row){
	interesting_column = int(basis(j,1));
	/*basis(j,0) = min_row;
	  basis(j,1) = i; */
	break;
      } 
    }
    
    // Now min_row is the row and i is the column to pivot on.
    Matrix Id;
    switch(min_case)
      {
      case CASE_A:
	for(k = 0; k < nr; k++)
	  {
	    T(k,i) = -T(k,i);
	    T(k,nc-1) += T(k,i);
	  }
	which_bound(i) = -which_bound(i);
	break;
      case CASE_B:
	T = pivot(T,min_row,i);
	for(j=0;j<nr;j++)
	  {
	    if(basis(j,0) == min_row)
	      { // This row was just pivoted out
		basis(j,0) = min_row;
		basis(j,1) = i;
		break;
	      }
	  }
	break;
      case CASE_C:
	which_bound(min_row) = -which_bound(min_row);
	T(min_row,interesting_column) = -T(min_row,interesting_column);
	T(min_row,nc-1) -= upper_bounds(interesting_column);
	T = pivot(T,min_row,i);// Be careful about the one below
	for(j=0;j<nr;j++)
	  {
	    if(basis(j,0) == min_row)
	      { // This row was just pivoted out
		basis(j,0) = min_row;
		basis(j,1) = i;
		break;
	      }
	  }
	break;
      default:
	break;
      }
  }
  return(T);
}

// A should be a tableau without the cost on the bottom. basis stores the current basis.  
static ColumnVector extract_solution(Matrix A,Matrix basis,ColumnVector upper_bounds,RowVector which_bound)
{
  ColumnVector x;
  int i;
  int nr = A.rows();
  int nc = A.cols()-1;
  if(basis.rows() != nr)
    {
      octave_stdout << "lp: internal error in extract_solution\n";
      octave_stdout << "please report this problem\n";
      octave_stdout << "A = \n" << A << "\n";
      octave_stdout << "basis =\n" << basis << "\n";
      octave_stdout << "nr = " << nr << ", basis.rows() = " << basis.rows() << "\n";
    }
  x = ColumnVector(nc,0.0);
  for(i=0;i<nr;i++)
    {
      if(basis(i,1) <= nc)
	{
	  x((int)rint(basis(i,1))) = A(i,nc);
	}
    }
  for(i=0;i<nc;i++)
    {
      if((which_bound(i) == -1) && (x(i) == 0))
	  x(i) = upper_bounds(i);
    }
  return(x);
}

int check_dimensions(RowVector c,Matrix A,ColumnVector b,ColumnVector vlb,ColumnVector vub)
{
  int errors = 0;
  int num_rows = A.rows();
  int num_cols = A.cols();

  if(Matrix(c).cols() != num_cols)
    {
      octave_stdout << "Columns in first arguement do not match rows in the second arguement.\n";
      errors--;
    }
  if(Matrix(b).rows() != num_rows)
    {
      octave_stdout << "The rows in the second arguement do not match the third arguement.\n";
      errors--;
    }
  if(Matrix(vlb).rows() != num_cols)
    {
      octave_stdout << "The columns in the second arguement do not match the fourth arguement.\n";
      errors--;
    }
  if(Matrix(vub).rows() != num_cols)
    {
      octave_stdout << "The columns in the second arguement do not match the fifth arguement.\n";
      errors--;
    }
  return(errors);
}

DEFUN_DLD(lp,args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {x =} lp(@var{f},@var{a},@var{b} [,@var{lb},@var{ub},@var{h}])\n\
Solve linear programming problems.\n\
\n\
min @var{f}*x\n\
 x  \n\
Subject to: @var{a}*x <= @var{b}\n\
\n\
@table @var\n\
@item f \n\
  @var{m} dimensional cost vector.\n\
@item a\n\
  @var{m}x@var{n} matrix representing the system.\n\
@item b\n\
  @var{n} dimensional vector.\n\
@item lb\n\
  Additional lower bound constraint vector on x.  Make\n\
  this -Infinity if you want no lower bound, but you\n\
  would like an upper bound or equality constraints.\n\
@item ub\n\
  Additional upper bound contraint vector on x.  If this\n\
  is Infinity that implies no upper bound constraint.\n\
@item h\n\
  An integer representing how many of the constraints are\n\
  equality constraints instead of inequality.\n\
@end table\n\
\n\
\n\
@end deftypefn" )
{
#ifdef HAVE_OCTAVE_20
  error("lp: unavaible in Octave 2.0");
  return octave_value_list();
#else  /* !HAVE_OCTAVE_20 */
  int i,j,k,l;
  octave_value_list retval;
  int nargin = args.length();
  int ne = 0; // The number of equality constraints
  int fatal_errors = 0;
  int include_in_basis;
  ColumnVector x;
  Matrix T;
  Matrix freeVars(1,2,0.0);
  int freeVarNum = 0;
  
  // Declarations of arguement variables
  RowVector c;
  Matrix A;
  ColumnVector b,vlb,vub,orig_vub;
  // Start checking arguements 
  if(nargin<3)
    {
      fatal_errors++;
    }
  else
    {
      c = RowVector(args(0).vector_value());
      A = args(1).matrix_value();
      b = ColumnVector(args(2).vector_value());
    }
  switch(nargin)
    {
    case 6:
      if(args(5).is_real_scalar())
	{
	  ne = int(args(5).double_value());
	}
      else
	{
	  cerr << "You must supply a scalar for the number of constraints that are equalities\n";
	  fatal_errors++;
	}
    case 5:
      vub = ColumnVector(args(4).vector_value());
      orig_vub = vub;
    case 4:
      vlb = ColumnVector(args(3).vector_value());
      break;
    case 3:
      break;
    default:
      cerr << "Incorrect number of arguements.\n";
      fatal_errors++;
    }

  int nr = A.rows();
  int nc = A.columns();
  
  if(check_dimensions(c,A,b,vlb,vub) < 0){fatal_errors++;}
  if(fatal_errors > 0){
    print_usage("lp");
    return(retval);
  }
  
  // Now take care of upper and lower bounds
  idx_vector aRange;
  idx_vector bRange(Range(1,nr));
  for(i =0;i<nc;i++)
    {
      if(vlb(i) > -octave_Inf)
	{
	  // Translate variable up;
	  // Make the {x_min < x < x_max} constraint now equal to {0 < x_new < x_max - x_min}
	  aRange = idx_vector(Range(i+1,i+1));
	  b = b-ColumnVector(Matrix(A.index(bRange,aRange))*double(vlb(i)));
	  // If the upper bound is Infinity we do not change it.  
	  if(vub(i) < octave_Inf){
	    vub(i) = vub(i)-vlb(i);
	  }
	}
      else if(vub(i) < octave_Inf)
	{
	  // Now we have the following constraint ==> {-Inf < x < x_max}
	  // After we are done it will be {0 < x_new < Inf}, where {x_new = -x+x_max}
	  b = b-ColumnVector(Matrix(A.index(bRange,aRange))*double(vub(i)));
	  T = identity_matrix(A.rows());
	  T(i,i) = -1.0;
	  A = A*T;
	  vub(i) = octave_Inf;
	}
      else
	{
	  // both bounds are infinity so make this into two variables;
	  // Now we have the following constraint -Inf < x < Inf 
	  // After we are done we have {0 < x1_new < Inf} and 
	  // {0 < x2_new < Inf} where {x = x1_new-x2_new} 
	  aRange = idx_vector(Range(i+1,i+1));
	  A = A.append(-Matrix(A.index(bRange,aRange)));
	  c = RowVector(Matrix(c).append(Matrix(1,1,-c(i))));
	  if(freeVarNum > 0)
	    {
	      freeVars.stack(Matrix(1,2,0.0));
	    }
	  freeVars(i,0) = i;
	  freeVars(i,1) = A.cols()-1;
	  freeVarNum++;
	  vub = ColumnVector(Matrix(vub).stack(Matrix(1,1,octave_Inf)));
	}
    }
  
  // find a basis.  Each row of basis holds where one element of the basis is. 
  // For example if [1,2] is on row 1 of basis then row 1 , column 2 is an 
  // element in the basis.   
  Matrix basis(nr,2,-1.0);
  RowVector which_bound(nc+freeVarNum,1.0);
  int index = 0;
  int slacks = 0;
  if(ne <= nr)
    {
      A = A.append(identity_matrix(nr,(nr-ne)));
      for(i=0;i<(nr-ne);i++)
	{
	  basis(i,1) = i+nc;
	  basis(i,0) = i;
	  index++;
	  slacks++;
	}
      which_bound = which_bound.append(RowVector(nr-ne,1.0));
      vub = vub.stack(ColumnVector(nr-ne,octave_Inf));
      c = c.append(RowVector(nr-ne,0));
    }
  else
    {
      octave_stdout << "It does not make sense to have more equalities than the rank of the system\n";
      return(retval);
    }
  
  if(index < nr)
    {
      include_in_basis = FALSE;
      // Loop over all columns
      for(i = 0;i < nc;i++)
	{
	  k=0;
	  // Decide if this column can be included in a basis
	  for(j = 0;j<nr;j++)
	    {
	      if(A(j,i) == 0){k++;}else{basis(index,0) =j;}
	      if((j-k) > 1){break; /* If there are already too many non-zero entries ... move on! */ }
	    }
	  if(k == (nr-1))
	    {
	      basis(index,1) = i;
	      include_in_basis = TRUE;
	      for(l = 0;l<index;l++)
		{// Make sure this is not already in the basis
		  if(basis(l,0) == basis(index,0))
		    {// Uh, oh!  it is in the basis.
		      include_in_basis = FALSE;
		      break;
		    }
		}
	      if(include_in_basis)
		{
		  // I believe this was extraneous
		  // A = pivot(A,int(basis(index,0)),int(basis(index,1)));
		  index++;
		  which_bound(i) = 1.0;
		  // This column can be included in the basis
		  if(index == nr){break;}
		}
	      else
		{
		  basis(index,0) = -1.0;
		  basis(index,1) = -1.0;
		}
	    }
	}
    }

  idx_vector tmp_rows;
  idx_vector tmp_cols; 
  if(index == nr)
    {
      // We have a full basis
      A = A.stack(Matrix(c));
      A = A.append(Matrix(b).stack(Matrix(1,1,0.0)));
      A = multi_pivot(A,basis);
      A = minimize(A,basis,vub,which_bound); 
      // now that we have the solution remove the slack variables.
      tmp_rows = Range(1,nr);
      tmp_cols = Range(1,nc+freeVarNum);
      T = Matrix(A.index(tmp_rows,tmp_cols));
      idx_vector tmp_cols2(Range(1,nc+freeVarNum));
      which_bound = RowVector(which_bound.index(tmp_cols2));
      idx_vector tmp_cols3(Range(nc+slacks+freeVarNum+1,A.cols()));
      T = T.append(Matrix(A.index(tmp_rows,tmp_cols3)));
    }
  else
    {
      // We still need to get a basis
      // I need to introduce artificial variable and solve the new lp in order to get a basis  
      int slop_columns = nr-index;
      int slop_column_index = 0;
      Matrix mp = Matrix(slop_columns,2,0.0);
      Matrix slop(nr,slop_columns,0.0);
      slop = slop.stack(Matrix(1,slop_columns,1.0));
      // loop over all rows looking to see which are not in the basis
      for(i=0;i<nr;i++)
	{
	  include_in_basis = TRUE;
	  // compare this row with each row in the basis
	  for(j=0;j<index;j++)
	    {
	      if(basis(j,0) == i)
		{
		  include_in_basis = FALSE;
		}
	    }
	  if(include_in_basis)
	    {
	      basis(index,0) = i;
	      basis(index,1) = nc+slop_column_index+freeVarNum;
	      slop(i,slop_column_index) = 1.0;
	      slop_column_index++;
	      index++;
	    }
	}
      which_bound = which_bound.append(RowVector(slop_column_index,1.0));
      T = A.stack(Matrix(1,A.columns(),0.0));
      T = T.append(slop);
      T = T.append(Matrix(b).stack(Matrix(1,1,0.0)));
      tmp_rows = Range(nr-slop_columns+1,nr);
      tmp_cols = Range(1,2);
      T = multi_pivot(T,Matrix(basis.index(tmp_rows,tmp_cols)));
      T = minimize(T,basis,vub,which_bound);
      // Go ahead and reuse the idx_vectors
      tmp_cols = Range(1,nc+freeVarNum);
      tmp_rows = Range(1,nr);
      A = Matrix(T.index(tmp_rows,tmp_cols));
      tmp_rows = Range(1.0,1.0);
      tmp_cols = Range(1,nc+freeVarNum);
      Matrix temp = Matrix(which_bound);
      temp = Matrix(temp.index(tmp_rows,tmp_cols));
      which_bound = RowVector(temp);
      A = A.stack(Matrix(c));
      tmp_cols = Range(T.cols(),T.cols());
      T(nr+1,T.cols()) = 0; 
      tmp_rows = Range(1,nr+1);
      temp = Matrix(T.index(tmp_rows,tmp_cols));
      A = A.append(temp);
      A = multi_pivot(A,basis);
      // Finally, I solve the problem.
      T = minimize(A,basis,vub,which_bound);
      // now remove the bottom row -- the cost
      tmp_cols = Range(1,T.cols());
      tmp_rows = Range(1,T.rows()-1);
      T = Matrix(T.index(tmp_rows,tmp_cols));
    }
  x = extract_solution(T,basis,vub,which_bound);
  // --------------------------------------------------------
  idx_vector cRange;
  bRange = Range(1,1);
  for(j=0,i=0;i<nc;i++)
    {
      if(vlb(i) > -octave_Inf)
	{
	  // Make the {x_min < x < x_max} constraint now equal to {0 < x_new < x_max - x_min}
	  x(i) = x(i)-vlb(i);
	}
      else if(orig_vub(i) < octave_Inf)
	{
	  // Translate negative variable up;
	  x(i) = -x(i)+orig_vub(i);
	}
      else
	{
	  // both bounds are infinity so make this into two variables;
	  if(x((int)rint(freeVars(j,0))) != 0)
	    {
	      if(x((int)rint(freeVars(j,1))) != 0)
		{
		  // This should be a mathematical impossibility!
		  octave_stdout << "You have found a bug in lp.\n";
		  octave_stdout << "Something that should be mathematically impossible occured\n";
		  octave_stdout << "The answer given may or may not be correct\n";
		  octave_stdout << "Please report the problem\n";
		}
	      T = Matrix(x);
	      aRange = idx_vector(Range(1,freeVars(j,1)-1));
	      if(freeVars(j,1) < T.rows())
		{
		  cRange = idx_vector(Range(freeVars(j,1)+1,T.rows()));
		  T = Matrix(T.index(aRange,bRange)).stack(Matrix(T.index(cRange,bRange)));
		}
	      else
		{
		  T = Matrix(T.index(aRange,bRange));
		}
	      x = ColumnVector(T);	
	    }
	  else if(x((int)rint(freeVars(j,1))) != 0)
	    {
	      // This means that a free variable is nagative  
	      x((int)rint(freeVars(j,0))) = -x((int)rint(freeVars(j,1)));
	      T = Matrix(x);
	      aRange = idx_vector(Range(1,freeVars(j,1)));
	      if(freeVars(j,1) < (T.rows()-1))
		{
		  cRange = idx_vector(Range(freeVars(j,1)+1,T.rows()));
		  T = Matrix(T.index(aRange,bRange)).stack(Matrix(T.index(cRange,bRange)));
		}
	      else
		{
		  T = Matrix(T.index(aRange,bRange));
		}
	      x = ColumnVector(T);	
	    }
	  else
	    {
	      // This means that both variables are zero.
	      // I simply remove the extra one and proceed as normal
	      T = Matrix(x);
	      aRange = idx_vector(Range(1,freeVars(j,1)));
	      if(freeVars(j,1) < T.rows())
		{
		  cRange = idx_vector(Range(freeVars(j,1)+1,T.rows()));
		  T = Matrix(T.index(aRange,bRange)).stack(Matrix(T.index(cRange,bRange)));
		}
	      else
		{
		  T = Matrix(T.index(aRange,bRange));
		}	
	      x = ColumnVector(T);
	    }
	}
    }
  // --------------------------------------------------------
  
  return(x);
#endif /* !HAVE_OCTAVE_20 */
}
