#include <iostream.h>
#include <math.h>

#include <octave/oct.h>

#include <octave/parse.h>
#include <octave/pager.h>

#define max(a,b) (((a)<(b)) ? (b) : (a))
#define min(a,b) (((a)<(b)) ? (a) : (b))

//////////////////////////////////////////////////


void GramSchmidt(Matrix &V, ColumnVector &norms,int Vr, int Vc){
  double tmp=0.0;
  for(int i=0; i<Vc; i++){
    tmp=0.0;  // normalize column i
    for(int j=Vr-1;j>=0;j--){tmp += V(j,i)*V(j,i);}
    tmp = norms(i)= sqrt(tmp);
    for(int j=Vr-1;j>=0;j--){V(j,i)/=tmp;}
    for(int k=i+1;k<Vc;k++){
      tmp=0.0; // scalar product tmp=<V(:,i),V(:,k)>
      for(int kk=Vr-1;kk>=0;kk--) tmp += V(kk,i)*V(kk,k);
      // V(:,k) = V(:,k)-tmp*A(:,i)
      for(int kk=Vr-1;kk>=0;kk--) V(kk,k) -= tmp*V(kk,i);  
    };
  };
};

//////////////////////////////////////////////////


DEFUN_DLD (GramSchmidt, args, , "[...] = GramSchmidt(...)\n\
  apply the Gram Schmidt reduction to the columns of a matrix V

  Vout = GramSchmidt(V)
  [Vout, ColLength] = GramSchmidt(V)

   V    is is a matrix of size mxn
   Vout is is a matrix of size mxn, 
        the columns of Vout are orthonormalized and we have
        span(V(:,1:k)) = span(Vout(:,1:k)) for k=1...n
   ColLength is a vector containing the lengths of the column vectors of V
        during the Gram Schmidt algorithm

   The implementation is based of the modified Gram Schmidt algorithm as 
   described in \"Matrix Computations\" by G. Golub and C. van Loan 
   
")

{
  octave_value_list retval;
  
  int nargin = args.length ();
  if (nargin != 1) {
    print_usage ("GramSchmidt");
    return retval;
  }

  octave_value V_arg = args(0);
  int col = V_arg.columns();
  int row = V_arg.rows();
  Matrix V= V_arg.matrix_value();
  
  ColumnVector ColLength(col);
  
  GramSchmidt(V,ColLength,row,col);
  
  retval(0)= V;
  retval(1)= ColLength;
  return retval;
}
