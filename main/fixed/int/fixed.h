/*

Copyright (C) 2001-2003 Motorola Inc
Copyright (C) 2001-2003 Laurent Mazet
Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (__int_fixed_h)
#define __int_fixed_h 1


#include <iosfwd>
#include <string>

#if defined(OCTAVE_FORGE)

#  include <octave/config.h>
#  include <octave/lo-utils.h>
#  include <octave/lo-error.h>
#  include <octave/error.h>

#  if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#    pragma interface
#  endif

#  define fixed_error(code) { error ("%s", Fixed::message[code]); }
#  define fixed_warning(code) { warning ("%s", Fixed::message[code]); }

#else

#  include "config.h"

#  define fixed_error(code) Fixed::_error (__FILE__, __LINE__, code)
#  define fixed_warning(code) Fixed::_warning (__FILE__, __LINE__, code)

#endif

#include "fixedversion.h"

#if (SIZEOF_FIXED == 2)
typedef unsigned short int fp_uint;
typedef short int fp_int;
#elif (SIZEOF_FIXED == 4)
typedef unsigned long int fp_uint;
typedef long int fp_int;
#elif (SIZEOF_FIXED == 8)
typedef unsigned long long fp_uint;
typedef long long fp_int;
#else
typedef unsigned int fp_uint;
typedef int fp_int;
#if defined(SIZEOF_FIXED)
#undef SIZEOF_FIXED
#endif
#define SIZEOF_FIXED SIZEOF_INT
#endif
const unsigned int maxfixedsize = SIZEOF_FIXED * 8 - 2;
const unsigned int halffixedsize = SIZEOF_FIXED * 4;

// Mingw defines a macro ERROR that will cause some pain here.
#ifdef ERROR
#undef ERROR
#endif

class FixedPoint
{
private:

  // FixedPoint structure

  fp_uint number;

  unsigned int decsize;
  unsigned int intsize;

  fp_uint filter;

  // Just for debugging

  double value;

public:

  // FixedPoint de-structurors
  int sign () const {
    if (number == 0)
      return 0;
    else
      return ((number >> (decsize+intsize)) & 1 ? -1 : 1);
  }

  char signbit () const {
    return ((number >> (decsize+intsize)));
  }
  
  friend int sign (FixedPoint &x) {
    return (x.sign());
  }

  friend char signbit (FixedPoint &x) {
    return (x.signbit());
  }

  double fixedpoint() const;

  friend double fixedpoint(const FixedPoint &x) {
    return (x.fixedpoint());
  }

  int getdecsize () const {
    return (decsize);
  }

  friend int getdecsize (FixedPoint &x) {
    return (x.getdecsize());
  }

  int getintsize () const {
    return (intsize);
  }
  
  friend int getintsize (FixedPoint &x) {
    return (x.getintsize());
  }

  fp_uint getnumber () const {
    return (number);
  }
  
  friend fp_uint getnumber (FixedPoint &x) {
    return (x.getnumber());
  }

  // FixedPoint constructor

  FixedPoint () :  number(0), decsize(0), intsize(0),
                          filter(0), value(0.0) { }

  FixedPoint (unsigned int is, unsigned int ds, const fp_uint n = 0);

  FixedPoint (unsigned int is, unsigned int ds,
              const fp_uint i, const fp_uint d);
  
  FixedPoint (unsigned int is, unsigned int ds, const FixedPoint &x);
  
  FixedPoint (unsigned int is, unsigned int ds, const double x);
  
  FixedPoint (const fp_int x);

  FixedPoint (const double x);

  FixedPoint (const FixedPoint &x) : number(x.number), decsize(x.decsize),
                                     intsize(x.intsize), filter(x.filter),
                                     value(x.value) { }

  // Changing FixedPoint dynamic

  FixedPoint chintsize (const int n) {
    return (FixedPoint (n, decsize, *this));
  }

  FixedPoint chdecsize (const int n) {
    return (FixedPoint (intsize, n, *this));
  }

  FixedPoint incintsize (const int n) {
    return (FixedPoint (intsize+n, decsize, *this));
  }

  FixedPoint incdecsize (const int n) {
    return (FixedPoint (intsize, decsize+n, *this));
  }
 
  FixedPoint incintsize () {
    return (FixedPoint (intsize+1, decsize, *this));
  }

  FixedPoint incdecsize () {
    return (FixedPoint (intsize, decsize+1, *this));
  }
 
  // FixedPoint intern operators

  FixedPoint &operator = (const fp_int &x);

  FixedPoint &operator = (const FixedPoint &x);
  
  FixedPoint &operator += (const FixedPoint &x);
  
  FixedPoint &operator -= (const FixedPoint &x);

  FixedPoint &operator *= (const FixedPoint &x);
  
  FixedPoint &operator /= (const FixedPoint &x);

  FixedPoint &operator <<= (const int s);

  FixedPoint &operator >>= (const int s);
  

  // FixedPoint unary operators

  FixedPoint &operator ++ ();

  FixedPoint &operator -- ();

  FixedPoint operator ++ (int);

  FixedPoint operator -- (int);
  
  friend FixedPoint operator + (const FixedPoint &x) {
    return FixedPoint(x);
  }
  
  friend FixedPoint operator - (const FixedPoint &x);

  friend FixedPoint operator ! (const FixedPoint &x);
  
  // FixedPoint operators

  friend FixedPoint operator +  (const FixedPoint &x, const FixedPoint &y) {
    FixedPoint x1(x);
    return (x1 += y);
  }

  friend FixedPoint operator -  (const FixedPoint &x, const FixedPoint &y) {
    FixedPoint x1(x);
    return (x1 -= y);
  }
  
  friend FixedPoint operator *  (const FixedPoint &x, const FixedPoint &y) {
    FixedPoint x1(x);
    return (x1 *= y);
  }
  
  friend FixedPoint operator /  (const FixedPoint &x, const FixedPoint &y) {
    FixedPoint x1(x);
    return (x1 /= y);
  }
    
  friend FixedPoint operator <<  (const FixedPoint &x, const int s) {

    FixedPoint n = x;
    return (n <<= s);
  }

  friend FixedPoint operator >>  (const FixedPoint &x, const int s) {

    FixedPoint n = x;
    return (n >>= s);
  }
  
  // FixedPoint comparators

  friend bool operator ==  (const FixedPoint &x, const FixedPoint &y);

  friend bool operator !=  (const FixedPoint &x, const FixedPoint &y);

  friend bool operator >  (const FixedPoint &x, const FixedPoint &y);
  
  friend bool operator >=  (const FixedPoint &x, const FixedPoint &y);
  
  friend bool operator <  (const FixedPoint &x, const FixedPoint &y);
  
  friend bool operator <=  (const FixedPoint &x, const FixedPoint &y);
  
  // FixedPoint shifting functions

  friend FixedPoint rshift(const FixedPoint &x, int s = 1);
  
  friend FixedPoint lshift(const FixedPoint &x, int s = 1);
  
  // FixedPoint mathematic functions

  friend FixedPoint real  (const FixedPoint &x);
  friend FixedPoint imag  (const FixedPoint &x);
  friend FixedPoint conj  (const FixedPoint &x);

  friend FixedPoint abs  (const FixedPoint &x);
  friend FixedPoint cos  (const FixedPoint &x);
  friend FixedPoint cosh  (const FixedPoint &x);
  friend FixedPoint sin  (const FixedPoint &x);
  friend FixedPoint sinh  (const FixedPoint &x);
  friend FixedPoint tan  (const FixedPoint &x);
  friend FixedPoint tanh  (const FixedPoint &x);

  friend FixedPoint sqrt  (const FixedPoint &x);
  friend FixedPoint pow  (const FixedPoint &w, const int y);
  friend FixedPoint pow  (const FixedPoint &x, const double y);
  friend FixedPoint pow  (const FixedPoint &x, const FixedPoint &y);
  friend FixedPoint exp  (const FixedPoint &x);
  friend FixedPoint log  (const FixedPoint &x);
  friend FixedPoint log10  (const FixedPoint &x);

  friend FixedPoint atan2 (const FixedPoint &x, const FixedPoint &y);

  friend FixedPoint round (const FixedPoint &x);
  friend FixedPoint rint (const FixedPoint &x);
  friend FixedPoint floor (const FixedPoint &x);
  friend FixedPoint ceil (const FixedPoint &x);

  // FixedPoint I/O functions

  friend std::istream &operator >>  (std::istream &is, FixedPoint &x);
  friend std::ostream &operator <<  (std::ostream &os, const FixedPoint &x);

  friend std::string getbitstring (const FixedPoint &x);

};


// Summary of the number of FixedPoint operations;

class FixedPointOperation {

  friend class FixedPoint;
  friend FixedPoint operator ! (const FixedPoint &x);
  friend FixedPoint operator - (const FixedPoint &x);
  friend bool operator == (const FixedPoint &x, const FixedPoint &y);
  friend bool operator != (const FixedPoint &x, const FixedPoint &y);
  friend bool operator > (const FixedPoint &x, const FixedPoint &y);
  friend bool operator >= (const FixedPoint &x, const FixedPoint &y);
  friend bool operator < (const FixedPoint &x, const FixedPoint &y);
  friend bool operator <= (const FixedPoint &x, const FixedPoint &y);
  friend FixedPoint real (const FixedPoint &x);
  friend FixedPoint imag (const FixedPoint &x);
  friend FixedPoint conj (const FixedPoint &x);
  friend FixedPoint abs (const FixedPoint &x);
  friend FixedPoint cos (const FixedPoint &x);
  friend FixedPoint cosh (const FixedPoint &x);
  friend FixedPoint sin (const FixedPoint &x);
  friend FixedPoint sinh (const FixedPoint &x);
  friend FixedPoint tan (const FixedPoint &x);
  friend FixedPoint tanh (const FixedPoint &x);
  friend FixedPoint sqrt(const FixedPoint &x);
  friend FixedPoint pow (const FixedPoint &w, const int y);
  friend FixedPoint pow (const FixedPoint &x, const double y);
  friend FixedPoint pow (const FixedPoint &x, const FixedPoint &y);
  friend FixedPoint exp (const FixedPoint &x);
  friend FixedPoint log (const FixedPoint &x);
  friend FixedPoint log10 (const FixedPoint &x);
  friend FixedPoint atan2 (const FixedPoint &x, const FixedPoint &y);
  friend FixedPoint round (const FixedPoint &x);
  friend FixedPoint rint (const FixedPoint &x);
  friend FixedPoint floor (const FixedPoint &x);
  friend FixedPoint ceil (const FixedPoint &x);

private:

  unsigned int nb_add;
  unsigned int nb_sub;
  unsigned int nb_mult;
  unsigned int nb_div;

  unsigned int nb_lshift;
  unsigned int nb_rshift;

  unsigned int nb_inc;
  unsigned int nb_dec;

  unsigned int nb_neg;
  unsigned int nb_comp;

  unsigned int nb_eq;
  unsigned int nb_neq;
  unsigned int nb_gt;
  unsigned int nb_ge;
  unsigned int nb_lt;
  unsigned int nb_le;

  unsigned int nb_cos;
  unsigned int nb_cosh;
  unsigned int nb_sin;
  unsigned int nb_sinh;
  unsigned int nb_tan;
  unsigned int nb_tanh;

  unsigned int nb_sqrt;
  unsigned int nb_pow;
  unsigned int nb_exp;
  unsigned int nb_log;
  unsigned int nb_log10;

  unsigned int nb_atan2;

  unsigned int nb_round;
  unsigned int nb_rint;
  unsigned int nb_floor;
  unsigned int nb_ceil;

public:

  FixedPointOperation();

  void reset ();

  friend std::ostream &operator << (std::ostream &os, 
                                    const FixedPointOperation &x);
};

// Global constants

namespace Fixed {

  const int MaxComment = 256;

  // Some of these aren't used. Delete them??
  typedef enum { ERROR = 0,
                 GET,
                 WRONGFIXSIZE,
		 BADMATH,
		 WARNING,
		 NAN_CONST,
		 INF_CONST,
                 LOSS_MSB_FP,
                 LOSS_MSB_INT,
                 LOSS_MSB_DEC,
                 LOSS_MSB_DB,
                 LOSS_MSB_ADD,
                 LOSS_MSB_SUB,
                 LOSS_MSB_MULT,
                 LOSS_MSB_LSHIFT,
		 LOSS_MSB_PRE_INC,
		 LOSS_MSB_PRE_DEC,
		 LOSS_MSB_POST_INC,
		 LOSS_MSB_POST_DEC } Code;

#if !defined(OCTAVE_FORGE)
  void _error (char *file, int line, Code code = ERROR);
  void _warning (char *file, int line, Code code = WARNING);
#endif

#if !defined (__int_fixed_cc)
  extern const char *FP_Version;

  extern const char *message[];

  extern bool FP_Debug;

  extern bool FP_Overflow;

  extern bool FP_CountOperations;

  extern FixedPointOperation FP_Operations;
#else
  const char *FP_Version = FIXEDVERSION;

  const char *message[19] =
  { "Error",
    "Not enough data",
    "Wrong fixed point size",
    "Bad real math",
    "Warning",
    "Not a number (NaN) in FixedPoint constructor",
    "Infinite value (Inf) in FixedPoint constructor",
    "Losing most significant bits in FixedPoint constructor",
    "Losing most significant bits in integer constructor (integer part)",
    "Losing most significant bits in integer constructor (fractional part)",
    "Losing most significant bits in double constructor",
    "Losing most significant bits in addition operator",
    "Losing most significant bits in subtraction operator",
    "Losing most significant bits in multiplication operator",
    "Losing most significant bits in left shift operator",
    "Losing most significant bits in pre-increment operator",
    "Losing most significant bits in pre-decrement operator",
    "Losing most significant bits in post-increment operator",
    "Losing most significant bits in post-decrement operator"
  };

  bool FP_Debug = false;

  bool FP_Overflow = false;

  bool FP_CountOperations = false;

  FixedPointOperation FP_Operations;
#endif
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
