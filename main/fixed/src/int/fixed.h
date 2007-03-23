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
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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

class OCTAVE_FIXED_API FixedPoint
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
  
  friend int sign (FixedPoint &x);

  friend char signbit (FixedPoint &x);

  double fixedpoint() const;

  friend double fixedpoint(const FixedPoint &x);

  int getdecsize () const {
    return (decsize);
  }

  friend int getdecsize (FixedPoint &x);

  int getintsize () const {
    return (intsize);
  }
  
  friend int getintsize (FixedPoint &x);

  fp_uint getnumber () const {
    return (number);
  }
  
  friend fp_uint getnumber (FixedPoint &x);

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

#ifdef _MSC_VER
  FixedPoint (const long double x) { *this = FixedPoint((const double)x); }

  operator double () const { return fixedpoint(); }
#endif

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
  
  friend FixedPoint operator + (const FixedPoint &x);
  
  friend OCTAVE_FIXED_API FixedPoint operator - (const FixedPoint &x);

  friend OCTAVE_FIXED_API FixedPoint operator ! (const FixedPoint &x);
  
  // FixedPoint operators

  friend FixedPoint operator +  (const FixedPoint &x, const FixedPoint &y);

  friend FixedPoint operator -  (const FixedPoint &x, const FixedPoint &y);
  
  friend FixedPoint operator *  (const FixedPoint &x, const FixedPoint &y);
  
  friend FixedPoint operator /  (const FixedPoint &x, const FixedPoint &y);
    
  friend FixedPoint operator <<  (const FixedPoint &x, const int s);

  friend FixedPoint operator >>  (const FixedPoint &x, const int s);
  
  // FixedPoint comparators

  friend OCTAVE_FIXED_API bool operator ==  (const FixedPoint &x, const FixedPoint &y);

  friend OCTAVE_FIXED_API bool operator !=  (const FixedPoint &x, const FixedPoint &y);

  friend OCTAVE_FIXED_API bool operator >  (const FixedPoint &x, const FixedPoint &y);
  
  friend OCTAVE_FIXED_API bool operator >=  (const FixedPoint &x, const FixedPoint &y);
  
  friend OCTAVE_FIXED_API bool operator <  (const FixedPoint &x, const FixedPoint &y);
  
  friend OCTAVE_FIXED_API bool operator <=  (const FixedPoint &x, const FixedPoint &y);
  
  // FixedPoint shifting functions

  friend OCTAVE_FIXED_API FixedPoint rshift(const FixedPoint &x, int s);
  
  friend OCTAVE_FIXED_API FixedPoint lshift(const FixedPoint &x, int s);
  
  // FixedPoint mathematic functions

  friend OCTAVE_FIXED_API FixedPoint real  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint imag  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint conj  (const FixedPoint &x);
  friend FixedPoint arg  (const FixedPoint &x);

  friend OCTAVE_FIXED_API FixedPoint abs  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint cos  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint cosh  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint sin  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint sinh  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint tan  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint tanh  (const FixedPoint &x);

  friend OCTAVE_FIXED_API FixedPoint sqrt  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint pow  (const FixedPoint &w, const int y);
  friend OCTAVE_FIXED_API FixedPoint pow  (const FixedPoint &x, const double y);
  friend OCTAVE_FIXED_API FixedPoint pow  (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API FixedPoint exp  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint log  (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint log10  (const FixedPoint &x);

  friend OCTAVE_FIXED_API FixedPoint atan2 (const FixedPoint &x, const FixedPoint &y);

  friend OCTAVE_FIXED_API FixedPoint round (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint rint (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint floor (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint ceil (const FixedPoint &x);

  // FixedPoint I/O functions

  friend OCTAVE_FIXED_API std::istream &operator >>  (std::istream &is, FixedPoint &x);
  friend OCTAVE_FIXED_API std::ostream &operator <<  (std::ostream &os, const FixedPoint &x);

  friend OCTAVE_FIXED_API std::string getbitstring (const FixedPoint &x);

};


// Summary of the number of FixedPoint operations;

class OCTAVE_FIXED_API FixedPointOperation {

  friend class FixedPoint;
  friend OCTAVE_FIXED_API FixedPoint operator ! (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint operator - (const FixedPoint &x);
  friend OCTAVE_FIXED_API bool operator == (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API bool operator != (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API bool operator > (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API bool operator >= (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API bool operator < (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API bool operator <= (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API FixedPoint real (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint imag (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint conj (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint abs (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint cos (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint cosh (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint sin (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint sinh (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint tan (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint tanh (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint sqrt(const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint pow (const FixedPoint &w, const int y);
  friend OCTAVE_FIXED_API FixedPoint pow (const FixedPoint &x, const double y);
  friend OCTAVE_FIXED_API FixedPoint pow (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API FixedPoint exp (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint log (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint log10 (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint atan2 (const FixedPoint &x, const FixedPoint &y);
  friend OCTAVE_FIXED_API FixedPoint round (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint rint (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint floor (const FixedPoint &x);
  friend OCTAVE_FIXED_API FixedPoint ceil (const FixedPoint &x);

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

  friend OCTAVE_FIXED_API std::ostream &operator << (std::ostream &os, 
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
  extern OCTAVE_FIXED_API const char *FP_Version;

  extern OCTAVE_FIXED_API const char *message[];

  extern OCTAVE_FIXED_API bool FP_Debug;

  extern OCTAVE_FIXED_API bool FP_Overflow;

  extern OCTAVE_FIXED_API bool FP_CountOperations;

  extern OCTAVE_FIXED_API FixedPointOperation FP_Operations;
#else
  OCTAVE_FIXED_API const char *FP_Version = FIXEDVERSION;

  OCTAVE_FIXED_API const char *message[19] =
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

  OCTAVE_FIXED_API bool FP_Debug = false;

  OCTAVE_FIXED_API bool FP_Overflow = false;

  OCTAVE_FIXED_API bool FP_CountOperations = false;

  OCTAVE_FIXED_API FixedPointOperation FP_Operations;
#endif
};

// Declarations of fixed point functions
inline int sign (FixedPoint &x) {
 return (x.sign());
}

inline char signbit (FixedPoint &x) {
  return (x.signbit());
}

inline double fixedpoint(const FixedPoint &x) {
  return (x.fixedpoint());
}

inline int getdecsize (FixedPoint &x) {
  return (x.getdecsize());
}

inline int getintsize (FixedPoint &x) {
  return (x.getintsize());
}

inline fp_uint getnumber (FixedPoint &x) {
  return (x.getnumber());
}

inline FixedPoint operator + (const FixedPoint &x) {
  return FixedPoint(x);
}
  
OCTAVE_FIXED_API FixedPoint operator - (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint operator ! (const FixedPoint &x);
  
inline FixedPoint operator +  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1(x);
  return (x1 += y);
}

inline FixedPoint operator -  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1(x);
  return (x1 -= y);
}
  
inline FixedPoint operator *  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1(x);
  return (x1 *= y);
}
  
inline FixedPoint operator /  (const FixedPoint &x, const FixedPoint &y) {
  FixedPoint x1(x);
  return (x1 /= y);
}
   
#ifdef _MSC_VER
#define FIXED_OP(R, OP, T1, C1, T2, C2) \
inline R operator OP (T1 x, T2 y) { \
  return C1 (x) OP C2 (y); \
}
#define FIXED_OP2(R, OP, T) \
FIXED_OP(R, OP, const FixedPoint&, , T, FixedPoint) \
FIXED_OP(R, OP, T, FixedPoint, const FixedPoint&, )
#define FIXED_OPS(T) \
FIXED_OP2(FixedPoint, +, T) \
FIXED_OP2(FixedPoint, -, T) \
FIXED_OP2(FixedPoint, *, T) \
FIXED_OP2(FixedPoint, /, T) \
FIXED_OP2(bool, ==, T) \
FIXED_OP2(bool, !=, T) \
FIXED_OP2(bool, >, T) \
FIXED_OP2(bool, >=, T) \
FIXED_OP2(bool, <, T) \
FIXED_OP2(bool, <=, T)

FIXED_OPS(double)
FIXED_OPS(int)
#endif
  
inline FixedPoint operator <<  (const FixedPoint &x, const int s) {
  FixedPoint n = x;
  return (n <<= s);
}

inline FixedPoint operator >>  (const FixedPoint &x, const int s) {
  FixedPoint n = x;
  return (n >>= s);
}
  
OCTAVE_FIXED_API bool operator ==  (const FixedPoint &x, const FixedPoint &y);
OCTAVE_FIXED_API bool operator !=  (const FixedPoint &x, const FixedPoint &y);
OCTAVE_FIXED_API bool operator >  (const FixedPoint &x, const FixedPoint &y);
OCTAVE_FIXED_API bool operator >=  (const FixedPoint &x, const FixedPoint &y);
OCTAVE_FIXED_API bool operator <  (const FixedPoint &x, const FixedPoint &y);
OCTAVE_FIXED_API bool operator <=  (const FixedPoint &x, const FixedPoint &y);
  
OCTAVE_FIXED_API FixedPoint rshift(const FixedPoint &x, int s = 1);
OCTAVE_FIXED_API FixedPoint lshift(const FixedPoint &x, int s = 1);
  
OCTAVE_FIXED_API FixedPoint real  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint imag  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint conj  (const FixedPoint &x);
inline FixedPoint arg (const FixedPoint &x) {
  return FixedPoint (x.getintsize (), x.getdecsize ());
}

OCTAVE_FIXED_API FixedPoint abs  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint cos  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint cosh  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint sin  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint sinh  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint tan  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint tanh  (const FixedPoint &x);

OCTAVE_FIXED_API FixedPoint sqrt  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint pow  (const FixedPoint &w, const int y);
OCTAVE_FIXED_API FixedPoint pow  (const FixedPoint &x, const double y);
OCTAVE_FIXED_API FixedPoint pow  (const FixedPoint &x, const FixedPoint &y);
OCTAVE_FIXED_API FixedPoint exp  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint log  (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint log10  (const FixedPoint &x);

OCTAVE_FIXED_API FixedPoint atan2 (const FixedPoint &x, const FixedPoint &y);

OCTAVE_FIXED_API FixedPoint round (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint rint (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint floor (const FixedPoint &x);
OCTAVE_FIXED_API FixedPoint ceil (const FixedPoint &x);

OCTAVE_FIXED_API std::istream &operator >>  (std::istream &is, FixedPoint &x);
OCTAVE_FIXED_API std::ostream &operator <<  (std::ostream &os, const FixedPoint &x);
OCTAVE_FIXED_API std::ostream &operator <<  (std::ostream &os, const FixedPointOperation &x);

OCTAVE_FIXED_API std::string getbitstring (const FixedPoint &x);

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
