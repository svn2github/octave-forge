#include "ov-re-tri.h"


octave_tri::octave_tri(const Matrix &m, tri_type t):
  octave_matrix(m), tri(t)
{
}

octave_tri::octave_tri (const octave_tri& T):
  octave_matrix(T), tri(T.tri)
{
}

octave_tri::~octave_tri(void)
{
}

octave_value *octave_tri::clone(void)
{
  return new octave_tri(*this);
}

static octave_value *
tri_numeric_conversion_function(const octave_value& a)
{
  CAST_CONV_ARG (const octave_tri &);
  
  return new octave_matrix (v.matrix_value());
}

type_conv_fcn
octave_tri::numeric_conversion_function (void) const
{
  return tri_numeric_conversion_function;
}

octave_value * octave_tri::try_narrowing_conversion(void)
{
  octave_value *retval = octave_matrix::try_narrowing_conversion();

  if ( retval==0){
    int nr = matrix.rows ();
    int nc = matrix.cols ();
 
    bool istri=true;
    
    if(tri==Lower){
      for(int r=0; r<nr; r++)
	for(int c=r+1; c<nc; c++)
	  if(matrix(r,c)!=0.0){
	    istri=false;
	    break;
	  }
    }
    else if(tri==Upper){
      for(int c=0; c<nc; c++)
	for(int r=c+1; r<nr; r++)
	  if(matrix(r,c)!=0.0){
	    istri=false;
	    break;
	  }
    }
    else
      error("Not a triangular Matrix");

    if(!istri)
      retval = new octave_matrix (matrix);
  }

  return retval;
}

void octave_tri::assign (const octave_value_list& idx, const Matrix& rhs)
{
  octave_matrix::assign(idx, rhs);
  return;
}

octave_value octave_tri::transpose(void) const
{
  return new octave_tri(this->matrix_value().transpose(), tri_type(! bool(tri)));
}

void octave_tri::print (std::ostream& os, bool pr_as_read_syntax) const
{
  octave_matrix::print(os, pr_as_read_syntax);
  os << (tri == Upper ? "Upper" : "Lower") << " Triangular";
  newline(os);
}

DEFUNOP (transpose, tri)
{
  CAST_UNOP_ARG (const octave_tri&);
  return v.transpose ();
}

DEFBINOP(ldiv, tri, matrix)
{
  CAST_BINOP_ARGS (const octave_tri&, const octave_matrix&);
  const Matrix X = v1.matrix_value();
  const Matrix Y = v2.matrix_value();

  if(X.cols()!=Y.rows()){
    error("ldiv -- X.cols!=Y.rows");
    return octave_value();
  }
  
  if(X.cols()!=X.rows()){
    error("ldiv -- X not square matrix");
    return octave_value();
  }

  Matrix A(X.rows(), Y.cols());

  if (v1.tri_value() == octave_tri::Lower){
    for(int c=0; c< A.cols(); c++)
      for(int r=0; r<A.rows(); r++){
	double sum=Y(r,c);
	for(int i=0; i<r; i++)
	  sum=sum-X(r,i)*A(i,c);
	A(r,c)=sum/X(r,r);
      }
  }
  else if (v1.tri_value() == octave_tri::Upper){
    for(int c=0; c< A.cols(); c++)
      for(int r=A.rows()-1; r>=0;  r--){
	double sum=Y(r,c);
	for(int i=r+1; i<A.rows(); i++)
	  sum=sum-X(r,i)*A(i,c);
	A(r,c)=sum/X(r,r);
      }
  }
  else{
    error("Not a triangular matrix");
  }

  return A;
}

DEFASSIGNOP (assign, tri, matrix)
{
  CAST_BINOP_ARGS (octave_tri &, octave_matrix&);
  v1.assign(idx, v2.matrix_value());
  return octave_value();
}

void install_tri_ops(void)
{
  INSTALL_UNOP (op_transpose, octave_tri, transpose);
  INSTALL_UNOP (op_hermitian, octave_tri, transpose);

  INSTALL_BINOP (op_ldiv, octave_tri, octave_matrix, ldiv);
  INSTALL_ASSIGNOP (op_asn_eq, octave_tri, octave_matrix, assign);
}


DEFINE_OCTAVE_ALLOCATOR (octave_tri);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_tri, "tri");

