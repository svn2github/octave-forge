// Copyright (C) 2002 Andreas Stahel
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

#include <iostream>
#include <cmath>

#include <octave/oct.h>

#include <octave/parse.h>
#include <octave/pager.h>

inline int max(int a, int b) { return a<b ? b : a; }
inline int min(int a, int b) { return a<b ? a : b; }
inline double max(double a, double b) { return a<b ? b : a; }
inline double min(double a, double b) { return a<b ? a : b; }

//////////////////////////////////////////////////

static
void BandMatrixTimesMatrix(Matrix &A, Matrix &B, Matrix &C, int length, int band, int bc){
  double tmp;
  int left  = min(band, length-band) ;
  int right = max(band, length-band) ;
  // Do the multiplication
  for(int Cc=0;Cc<bc; Cc++) {
    // left restricted, right full
    for(int r=0;r<min(left,right);r++){
      tmp=0.0;
      for (int c=r;c>0;c--){
	tmp += A(r-c,c)*B(r-c,Cc);
      }
      for (int c=band-1;c>=0;c--){
	tmp += A(r,c)*B(r+c,Cc);
      }
      C(r,Cc)=tmp;
    }
    if(band<=(length-band))
      // left full, right full
      for(int r=left ;r<right;r++){
	tmp=0.0;
	for (int c=band-1;c>0;c--){
	  tmp += A(r-c,c)*B(r-c,Cc);
	}
	for (int c=band-1;c>=0;c--){
	  tmp += A(r,c)*B(r+c,Cc);
	}
	C(r,Cc)=tmp;
      }
    else
      // left restricted, right restricted
      for(int r=left;r<right;r++){
	tmp=0.0;
	for (int c=r;c>0;c--){
	  tmp += A(r-c,c)*B(r-c,Cc);
	}
	for (int c=length-r-1;c>=0;c--){
	  tmp += A(r,c)*B(r+c,Cc);
	}
	C(r,Cc)=tmp;
    }
    
    // left full, right restricted
    for(int r=max(right,left);r<length;r++){
      tmp=0.0;
      for (int c=band-1;c>0;c--){
	tmp += A(r-c,c)*B(r-c,Cc);
      }
      for (int c=length-r-1;c>=0;c--){
	tmp += A(r,c)*B(r+c,Cc);
      }
      C(r,Cc)=tmp;
    }
  };
};

static
void BandMatrixTimesVector(Matrix &A, ColumnVector &B, ColumnVector &C, int length, int band){
  double tmp;

  // clear the result vector
  for(int r=length-1;r>=0;r--) C(r)=0.0;
  // Do the multiplication
  for(int r=0 ;r<length-band;r++){
    tmp=0.0;
    for(int j=band-1;j>=0;j--){
      tmp += A(r,j)*B(r+j);
      C(r+j)+=A(r,j)*B(r);
    };
  };
  for(int r=length-band ;r<length;r++){
    tmp=0.0;
    for(int j=length-r-1;j>=0;j--){
      tmp += A(r,j)*B(r+j);
      C(r+j)+=A(r,j)*B(r);
    }
  }
};


static  
void CholeskyFactorization(Matrix &A,int nr, int nc){
  int jMax;
  double tmp;

#define TOL 1e-12  // I need to come up with a better definition of TOL

// Do the factorization
#define NEW

#ifdef NEW
  double* tmprow;
  tmprow=new double[nc];
  for(int k=0; k<nr-1; k++) {
    if ( fabs(A(k,0))<=TOL ) {
      error("Problem at step # %d, possible division by 0", k);
      return  ;
    }
    jMax=min(nc,nr-k);
    for(int j=jMax-1;j>=0;j--){tmprow[j]=A(k,j);}
    for(int j=jMax-1;j>0;j--){
      tmp=A(k,j)=tmprow[j]/tmprow[0];
      for(int i=jMax-j-1;i>=0;i--) A(k+j,i) -= tmp*tmprow[j+i];
    };
  };
  delete[] tmprow;
  return;
#endif

#ifdef OLD
  for(int k=0; k<nr-1; k++) {
    if ( fabs(A(k,0))<=TOL ) {
      error("Problem at step # %d, possible division by 0", k);
      return  ;
    }
    jMax=min(nc,nr-k);
    for(int j=1;j<jMax;j++){
      tmp=A(k,j)/A(k,0);
      for(int i=jMax-j-1;i>=0;i--)
	A(k+j,i) -= tmp*A(k,j+i);
      A(k,j)=tmp;
    };
  };
  return;
#endif
};

static
void CholeskyFactorization2(Matrix &A,int nr, int nc){
  int jMax;
  double tmp;

#define TOL 1e-12  // I need to come up with a better definition of TOL

// Do the factorization
  double *pA = A.fortran_vec();  // will be modified
  double* tmprow;

  tmprow=new double[nc];
  for(int k=0; k<nr-1; k++) {
    if ( fabs(pA[k])<=TOL ) {
      error("Problem at step # %d, possible division by 0", k);
      return  ;
    }
    jMax=min(nc,nr-k);
    for(int j=jMax-1;j>=0;j--){tmprow[j]=pA[k+j*nr];}
    for(int j=jMax-1;j>0;j--){
      //tmp=A(k,j)=tmprow[j]/tmprow[0];
      pA[k+nr*j]=tmp=tmprow[j]/tmprow[0];
      //for(int i=jMax-j-1;i>=0;i--) pA[k+j+i*nr] -= tmp*tmprow[j+i];
      // counting i up or down does not seem to make a difference
      for(int i=0;i<jMax-j;i++) pA[k+j+i*nr] -= tmp*tmprow[j+i];
    };
  };
  delete[] tmprow;
  return;
};

static
void CholeskyFactorization3(Matrix &A,int nr, int nc){
  int jMax;
  double tmp;

#define TOL 1e-12  // I need to come up with a better definition of TOL

// Do the factorization
  double *pA = A.fortran_vec();  // will be modified

  int kj,k0j;
  kj=k0j=0;

  for(int k=0; k<nr-1; k++) {
    if ( fabs(pA[k])<=TOL ) {
      error("Problem at step # %d, possible division by 0", k);
      return  ;
    }
    jMax=min(nc,nr-k);
    kj=k0j=k;
    for(int j=1;j<jMax;j++){
      kj++;
      k0j += nr;
      tmp=pA[k0j]/pA[k];
      for(int i=nr*(jMax-j-1);i>=0;i-=nr){
	pA[kj+i] -= tmp*pA[k0j+i];}
      pA[k0j]=tmp;
    };
  };
  return;
};


static
void CholeskyBacksub(Matrix &R,Matrix &B,int nr, int nc, int bc){
#ifdef NEW
// Do Lower triangular substitution (LD)c=b -> c=D\L\b
  for(int i=0; i<nr; i++) 
    for(int j=0; j<bc; j++) {
      for(int k=min(nr-i,nc)-1;k>0; k--)
	B(i+k,j)-= B(i,j)*R(i,k);
      B(i,j)/= R(i,0); 
    }; //for j

// Do Upper triangular substitution L'x=c -> x=L'\c
  for(int i=nr-1; i>=0; i--) 
    for(int j=0; j<bc; j++) {
      for(int k=min(i+1,nc)-1;k>0; k--)
	B(i-k,j)-= B(i,j)*R(i-k,k);
    }; //for j
#endif

#ifdef OLD
// Do Lower triangular substitution (LD)c=b -> c=D\L\b
  for(int i=0; i<nr; i++) 
    for(int j=0; j<bc; j++) {
      for(int k=1; k<min(nr-i,nc); k++)
	B(i+k,j)-= B(i,j)*R(i,k);
      B(i,j)/= R(i,0); 
    }; //for j

// Do Upper triangular substitution L'x=c -> x=L'\c
  for(int i=nr-1; i>=0; i--) 
    for(int j=0; j<bc; j++) {
      for(int k=1; k<min(i+1,nc); k++)
	B(i-k,j)-= B(i,j)*R(i-k,k);
    }; //for j
#endif
};

static
void CholeskyBacksub2(Matrix &R,Matrix &B,int nr, int nc, int bc){

  //double *pB = B.fortran_vec();  // will be modified
  //double *pR = R.data();     // will not be modified

// Do Lower triangular substitution (LD)c=b -> c=D\L\b
  for(int i=0; i<nr; i++) 
    for(int j=0; j<bc; j++) {
      for(int k=min(nr-i,nc)-1;k>0; k--)
	B.xelem(i+k,j)-= B.xelem(i,j)*R.xelem(i,k);
      B.xelem(i,j)/= R.xelem(i,0); 
    }; //for j

// Do Upper triangular substitution L'x=c -> x=L'\c
  for(int i=nr-1; i>=0; i--) 
    for(int j=0; j<bc; j++) {
      for(int k=min(i+1,nc)-1;k>0; k--)
	B.xelem(i-k,j)-= B.xelem(i,j)*R.xelem(i-k,k);
    }; //for j
};

static
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
      for(int kk=Vr-1;kk>=0;kk--) V(kk,k)-= tmp*V(kk,i);  
   };
 };
};

static
void GramSchmidtGen(Matrix &V,Matrix &V2,Matrix &B,ColumnVector &norms,int Vr, int Vc){
//  V will return the orthonormalized column vectors of V
//  V2 is used for temporary storage only
  double tmp=0.0;
  BandMatrixTimesMatrix(B,V,V2,B.rows(),B.columns(),V.columns());
  for(int i=0; i<Vc; i++){
    tmp=0.0;  // normalize column i
    for(int j=Vr-1;j>=0;j--){tmp += V2(j,i)*V(j,i);}
    tmp = norms(i)= sqrt(tmp);
    for(int j=Vr-1;j>=0;j--){V(j,i)/=tmp;}
    for(int k=i+1;k<Vc;k++){
      BandMatrixTimesMatrix(B,V,V2,B.rows(),B.columns(),V.columns());
      tmp=0.0; // scalar product tmp=<V(:,i),B*V(:,k)>
      for(int kk=Vr-1;kk>=0;kk--) tmp += V(kk,i)*V2(kk,k);
      // V(:,k) = V(:,k)-tmp*V(:,i)
      for(int kk=Vr-1;kk>=0;kk--) V(kk,k)-= tmp*V(kk,i);  
    };
  };
};

//////////////////////////////////////////////////


DEFUN_DLD (SBSolve, args, , "[...] = SBSolve (...)\n\
  solve a system of linear equations with a symmetric banded matrix\n\
\n\
  X=SBSolve(A,B)\n\
  [X,R]=SBSolve(A,B)\n\
\n\
   solves A X = B\n\
\n\
   A is mxt where t-1 is number of non-zero super diagonals\n\
   B is mxn\n\
   X is mxn\n\
   R is mxt\n\
\n\
  if A would be ! 11000 ! then A= ! 11 !\n\
                ! 14300 !         ! 43 !\n\
                ! 03520 !         ! 52 !\n\
                ! 00285 !         ! 85 !\n\
                ! 00059 !         ! 90 !\n\
\n\
  B is a full matrix\n\
\n\
  The code is based on a LDL' decomposition (use L=R'), without pivoting.\n\
  If A is positive definite, then it reduces to the Cholesky algorithm.\n\
\n\
  R is an upper right band matrix\n\
  The first column of R contains the entries of a diagonal matrix D.\n\
  If the first column of R is filled by 1's, then we have R'*D*R = A")
{
  octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 2) {
    print_usage ();
    return retval;
  }

  octave_value A_arg = args(0);
  int nr= A_arg.rows();
  int nc= A_arg.columns();

  octave_value B_arg = args(1);
  int bc= B_arg.columns();
  if (nr != B_arg.rows()) {
    error ("Columns in A and B not equal");
    return retval;
  }

  if ( A_arg.is_real_type() && B_arg.is_real_type() ) {

    Matrix A= A_arg.matrix_value();
    Matrix B= B_arg.matrix_value();
    B.fortran_vec(); // Force a copy of the array
    
    CholeskyFactorization2(A,nr,nc);
    CholeskyBacksub2(A,B,nr,nc,bc);

    retval(0)= B;
    retval(1)= A;
  }
  else {
    error ("Can't handle complex matrices yet!");
  };
  
  return retval;
}



DEFUN_DLD (SBFactor, args, , "[...] = SBFactor (...)\n\
  find the R'DR factorization of a symmetric banded matrix\n\
\n\
  R=SBFactor(A)\n\
\n\
   A is mxt where t-1 is number of non-zero super diagonals\n\
   R is mxt\n\
\n\
  if A would be ! 11000 ! then A= ! 11 !\n\
                ! 14300 !         ! 43 !\n\
                ! 03520 !         ! 52 !\n\
                ! 00285 !         ! 85 !\n\
                ! 00059 !         ! 90 !\n\
\n\
\n\
  The code is based on a LDL' decomposition (use L=R'), without pivoting.\n\
  If A is positive definite, then it reduces to the Cholesky algorithm.\n\
\n\
  R is an upper right band matrix\n\
  The first column of R contains the entries of a diagonal matrix D.\n\
  If the first column of R is filled by 1's, then we have R'*D*R = A")
{
  octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 1) {
    print_usage ();
    return retval;
  }

  octave_value A_arg = args(0);
  int nr= A_arg.rows();
  int nc= A_arg.columns();

  Matrix A = A_arg.matrix_value();
 
  CholeskyFactorization2(A,nr,nc);

  retval(0)= A;
  return retval;
}


DEFUN_DLD (SBFactor2, args, , "[...] = SBFactor (...)\n\
  find the R'DR factorization of a symmetric banded matrix\n\
\n\
  R=SBFactor(A)\n\
\n\
   A is mxt where t-1 is number of non-zero super diagonals\n\
   R is mxt\n\
\n\
  if A would be ! 11000 ! then A= ! 11 !\n\
                ! 14300 !         ! 43 !\n\
                ! 03520 !         ! 52 !\n\
                ! 00285 !         ! 85 !\n\
                ! 00059 !         ! 90 !\n\
\n\
  The code is based on a LDL' decomposition (use L=R'), without pivoting.\n\
  If A is positive definite, then it reduces to the Cholesky algorithm.\n\
\n\
  R is an upper right band matrix\n\
  The first column of R contains the entries of a diagonal matrix D. \n\
  If the first column of R is filled by 1's, then we have R'*D*R = A")
{
  octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 1) {
    print_usage ();
    return retval;
  }

  octave_value A_arg = args(0);
  int nr= A_arg.rows();
  int nc= A_arg.columns();

  Matrix A = A_arg.matrix_value();
 
  CholeskyFactorization2(A,nr,nc);

  retval(0)= A;
  return retval;
}


DEFUN_DLD (SBBacksub, args, , "[...] = SBBacksub (...)\n\
  using backsubstitution  to return the solution of a system of linear equations\n\
\n\
  X=SBBacksub(R,B)\n\
\n\
   B is mxn\n\
   X is mxn\n\
   R is mxt\n\
\n\
   R is produced by a call of [X,R] = SBSolve(A,B) or R = SBFactor(A)\n\
   It is an upper right band matrix\n\
   The first column of R contains the entries of a diagonal matrix D.\n\
   If the first column of R is filled by 1's, then we have R'*D*R = A")
{
  octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 2) {
    print_usage ();
    return retval;
  }

  octave_value R_arg = args(0);
  int nr= R_arg.rows();
  int nc= R_arg.columns();

  octave_value B_arg = args(1);
  int bc= B_arg.columns();
  if (nr != B_arg.rows()) {
    error ("Columns in R and B not equal");
    return retval;
  }

  Matrix R = R_arg.matrix_value();
  Matrix B = B_arg.matrix_value();

  CholeskyBacksub(R,B,nr,nc,bc);
  
  retval(0)= B;
  return retval;
}


DEFUN_DLD (SBProd, args, , "[...] = SBProd (...)\n\
  multiplies a symmetric banded matrix with a matrix\n\
\n\
  X=SBProd(A,B)\n\
\n\
   A is mxt where t-1 is number of non-zero superdiagonals\n\
   B is mxn\n\
   X is mxn\n\
\n\
  if A would be ! 11000 ! then A= ! 11 !\n\
                ! 14300 !         ! 43 !\n\
                ! 03520 !         ! 52 !\n\
                ! 00285 !         ! 85 !\n\
                ! 00059 !         ! 90 !\n\
\n\
  B is full matrix Ax=B")
{
  octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 2) {
    print_usage ();
    return retval;
  }

  octave_value A_arg = args(0);
  int band   = A_arg.columns();
  int length = A_arg.rows();

  octave_value B_arg = args(1);
  int bc= B_arg.columns();
  int br= B_arg.rows();
  if (length != br) {
    error ("Columns in A and rows B not equal (%d != %d)", length, br);
    return retval;
  }

  Matrix A= A_arg.matrix_value();
  Matrix B= B_arg.matrix_value();
  Matrix C(length,bc);

  BandMatrixTimesMatrix(A,B,C,length,band,bc);

 retval(0)= C;
 return retval;
}

DEFUN_DLD (SBEig, args, nargout , "[...] = SBEig (...)\n\
  find a few eigenvalues of the symmetric, banded matrix\n\
  inverse power iteration is used for the standard and generalized\n\
  eigenvalue problem\n\
\n\
  [Lambda,{Ev,err}] = SBEig(A,V,tol)     solve A*Ev = Ev*diag(Lambda)\n\
                    standard eigenvalue problem\n\
\n\
  [Lambda,{Ev,err}] = SBEig(A,B,V,tol)   solve A*Ev = B*Ev*diag(Lambda)\n\
                    generalized eigenvalue problem\n\
\n\
   A   is mxt, where t-1 is number of non-zero superdiagonals\n\
   B   is mxs, where s-1 is number of non-zero superdiagonals\n\
   V   is mxn, where n is the number of eigenvalues desired\n\
       contains the initial eigenvectors for the iteration\n\
   tol is the relative error, used as the stopping criterion\n\
\n\
   X   is a column vector with the eigenvalues\n\
   EV  is a matrix whose columns represent normalized eigenvectors\n\
   err is a vector with the aposteriori error estimates for the eigenvalues")
{
  octave_value_list retval;
  //  octave_value_list tmpargs;
  //  octave_value_list tmpresult;
  //  int tmpnargout;

  int nargin = args.length ();
  if ((nargin <2)||(nargin>4)) {
    print_usage ();
    return retval;
  }

  bool general=false;
  if (nargin==4) general=true;
  octave_value A_arg = args(0);
  int band   = A_arg.columns();
  int length = A_arg.rows();

  int neig;
  int lengthV;
  double tol;
  octave_value B_arg;
  octave_value V_arg;
    
  if (general){
    B_arg = args(1);
    V_arg = args(2);
    neig    = V_arg.columns(); // number of eigenvalues to be computed
    lengthV = V_arg.rows();
    tol = args(3).double_value();  
  }
  else{
    V_arg = args(1);
    neig    = V_arg.columns(); // number of eigenvalues to be computed
    lengthV = V_arg.rows();
    tol = args(2).double_value();
  }
  if (length != lengthV) {
    error ("Columns in A and V not equal");
    return retval;
  }

  ColumnVector eigen(neig);
  ColumnVector eigenold(neig);
  double tmp;

  //  octave_value tol_arg = args(2);
  //  Matrix A= A_arg.matrix_value();
  //  Matrix R= A;
  Matrix R= A_arg.matrix_value();
  Matrix V= V_arg.matrix_value();
  Matrix B;
  Matrix C;
  Matrix W;
  if (general)  B = B_arg.matrix_value();

  CholeskyFactorization(R,length,band);

  int count;
#define MAXCOUNTER 300  
  for(count=0;count<3;count++){  //3 iterations at least
    if (general){
      W=V;
      BandMatrixTimesMatrix(B,W,V,B.rows(),B.columns(),W.columns());
      CholeskyBacksub(R,V,length,band,neig);
      GramSchmidtGen(V,W,B,eigen,length,neig);
    }
    else{
      CholeskyBacksub(R,V,length,band,neig);
      GramSchmidt(V,eigen,length,neig);
    }
  }
  // iterate until tolerance or too many iterations
  double relerror=2*tol;
  for(count=3;(count<MAXCOUNTER)&&(relerror>tol);count++){
    eigenold=eigen;
    if (general){
      W=V;
      BandMatrixTimesMatrix(B,W,V,B.rows(),B.columns(),W.columns());
      CholeskyBacksub(R,V,length,band,neig);
      GramSchmidtGen(V,W,B,eigen,length,neig);    
    }
    else{
      CholeskyBacksub(R,V,length,band,neig);
      GramSchmidt(V,eigen,length,neig);
    }
    relerror=fabs(eigenold(0)/eigen(0)-1.0);
    for(int j=1;j<neig;j++)
      relerror=max(fabs(eigenold(j)/eigen(j)-1.0),relerror);
  }
  // end of iteration
  if (general){ // W=B*V
    BandMatrixTimesMatrix(B,V,W,B.rows(),B.columns(),V.columns());
    C=V;  // store it for aposteriori error
    V=W;
    CholeskyBacksub(R,W,length,band,neig);
    for(int j=0;j<neig;j++){
      tmp=0.0;
      for(int i=0;i<length;i++) tmp += V(i,j)*W(i,j);
      eigen(j)=1.0/tmp;
    }
    V=C;
  }
  else {
    W = V;
    CholeskyBacksub(R,W,length,band,neig);
    for(int j=0;j<neig;j++){
      tmp=0.0;
      for(int i=0;i<length;i++) tmp += V(i,j)*W(i,j);
      eigen(j)=1.0/tmp;
    }
  }

  if (count>=MAXCOUNTER) 
	octave_stdout<<"warning: too many iterations, possibly a convergence problem"<<std::endl;


 ColumnVector errorEst(neig);
 // a posteriori error estimate has to be computed
 if (nargout>=3){ 
    R=A_arg.matrix_value();
    if (general) {
    // W = A*C - B*C*diag(eigen)  // C contains the eigenvectors
	BandMatrixTimesMatrix(R,C,W,R.rows(),R.columns(),C.columns());
	BandMatrixTimesMatrix(B,C,V,B.rows(),B.columns(),C.columns());
	  for(int c=W.columns()-1;c>=0;c--){
	      for(int r=W.rows()-1;r>=0;r--){
		  W(r,c) -= V(r,c)*eigen(c);
	      }
	  }
	  // norms of <r ,B^{-1} r>
      //      Matrix Rb= B_arg.matrix_value();
      V=W;  // V=B^{-1}*W
      CholeskyFactorization(B,B.rows(),B.columns());
      CholeskyBacksub(B,V,B.rows(),B.columns(),neig);
      for(int c=W.columns()-1;c>=0;c--){
	tmp=0.0;
	for(int r=W.rows()-1;r>=0;r--) tmp+=V(r,c)*W(r,c);
	errorEst(c)=sqrt(tmp);
      }
      V=C; // V has to return the eigenvectors
    }
    else {
      // W = A*V - V*diag(eigen) 
      BandMatrixTimesMatrix(R,V,W,R.rows(),R.columns(),V.columns());
      for(int c=W.columns()-1;c>=0;c--){
	for(int r=W.rows()-1;r>=0;r--){
	  W(r,c)-=V(r,c)*eigen(c);
	}
      }
      //norms of the columns of W
      for(int c=W.columns()-1;c>=0;c--){
	tmp=0.0;
	for(int r=W.rows()-1;r>=0;r--) tmp+=W(r,c)*W(r,c);
	errorEst(c)=sqrt(tmp);
      }
    }
  }

  retval(0)= eigen;
  retval(1)= V;
  retval(2) = errorEst;
  return retval;
}
