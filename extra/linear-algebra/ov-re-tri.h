#include <octave/config.h>
#include <octave/lo-utils.h>
#include <octave/mx-base.h>
#include <octave/str-vec.h>
#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/lo-mappers.h>
#include <octave/oct-obj.h>
#include <octave/ops.h>
#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov.h>
#include <octave/ov-scalar.h>
#include <octave/ov-re-mat.h>
#include <octave/pager.h>
#include <octave/pr-output.h>
#include <octave/symtab.h>
#include <octave/variables.h>

class Octave_map;
class octave_value_list;

class tree_walker;

// Define the octave_sparse Class
class
octave_tri : public octave_matrix
{
public:
  enum tri_type{
    Upper=0,
    Lower=1
  };

   octave_tri(const Matrix &m, tri_type t);
   ~octave_tri(void);
   octave_tri (const octave_tri& D);

   octave_value *clone (void) const;

   type_conv_fcn numeric_conversion_function (void) const;
   octave_value * try_narrowing_conversion(void);

   inline tri_type tri_value(void) const { return tri;};
   void assign (const octave_value_list& idx, const Matrix& rhs);

   octave_value transpose (void) const ;
   void print (std::ostream& os, bool pr_as_read_syntax = false) const ;
private:
   tri_type tri;
   DECLARE_OCTAVE_ALLOCATOR
   DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
}; // class octave_diag

