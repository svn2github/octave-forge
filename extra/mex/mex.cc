// Author: Paul Kienzle, 2001-03-22
// I grant this code to the public domain.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

// 2001-06-21 Paul Kienzle <pkienzle@users.sf.net>
// * fix is_numeric so that character strings aren't called numeric.
// * use unsigned short for mxChar rather than char
// 2001-09-20 Paul Kienzle <pkienzle@users.sf.net>
// * Need <float.h> for DBL_EPSILON
// 2001-11-02 Paul Kienzle <pkienzle@users.sf.net>
// * fixed mxGetString to put in the zero-terminator

#include <float.h>
#include <iomanip.h>
extern "C" {
#include <stdlib.h>
#include <setjmp.h>
  extern const char *mexFunctionName;
} ;

#include <octave/oct.h>
#include <octave/pager.h>
#include <octave/SLList.h>
// XXX FIXME XXX --- this belongs in SLList.h, not SLList.cc
template <class T> SLList<T>::~SLList (void) { clear(); }
#include <octave/f77-fcn.h>
#include <octave/unwind-prot.h>
#include <octave/lo-mappers.h>
#include <octave/lo-ieee.h>
#include <octave/parse.h>
#include <octave/toplev.h>
#include <octave/variables.h>

// ================ Octave 2.0 support ==================
#if defined(HAVE_OCTAVE_20)
#include <octave/symtab.h>
class unwind_protect
{
public:
  static void add(cleanup_func fptr, void *ptr) 
  { 
    add_unwind_protect (fptr, ptr);
  }
  static void run(void)
  {
    run_unwind_protect ();
  }
} ;

static octave_value_list
eval_string (const string& s, int print, int& parse_status, int nargout) 
{
  return eval_string(s,print,parse_status);
}

static int
octave_vformat (std::ostream& os, const char *fmt, va_list args)
{
  int retval = -1;

#if defined (__GNUG__)

  ostrstream buf;
  buf.vform (fmt, args);
  buf << ends;
  char *s = buf.str ();
  os << s;
  retval = strlen (s);
  delete [] s;

#else

  char *s = octave_vsnprintf (fmt, args);
  if (s)
    {
      os << s;
      retval = strlen (s);
      free (s);
    }

#endif

  return retval;
}

#endif

#if 0
#define TRACEFN cout << __FUNCTION__ << endl << flush
#else
#define TRACEFN do { } while(0)
#endif

/* ============== mxArray data type ============= */
// Class mxArray is not much more than a struct for keeping together
// dimensions and data.  It doesn't even ensure consistency between
// the dimensions and the data.  Unfortunately you can't do better
// than this without restricting the operations available in Matlab
// for directly manipulating its mxArray type.

typedef unsigned short mxChar;
const int mxMAXNAM=64;

class mxArray {
public:
  ~mxArray () { }

  int rows() const { return nr; }
  int columns() const { return nc; }
  void rows(int r) { nr = r; }
  void columns(int c) { nc = c; }

  double *imag() const { return pi; }
  double *real() const { return pr; }
  void imag(double *p) { pi = p; }
  void real(double *p) { pr = p; }

  bool is_empty() const { return nr==0 || nc==0; }
  bool is_numeric() const { return !isstr && (pr != NULL || nr==0 || nc==0); }
  bool is_complex() const { return pi != NULL; }
  bool is_sparse() const { return false; }

  bool is_string() const { return isstr; }
  void is_string(bool set) { isstr = set; }

  const char* name() const { return aname; }
  void name(const char *nm) { 
    strncpy(aname,nm,mxMAXNAM); 
    aname[mxMAXNAM]='\0'; 
  }

  octave_value as_octave_value() const;

private:
  int nr, nc;
  double *pr, *pi;
  bool isstr;
  char aname[mxMAXNAM+1];
} ;

octave_value mxArray::as_octave_value() const
{
  octave_value ret;
  if (isstr)
    {
      charMatrix chm(nr,nc);
      char *pchm = chm.fortran_vec();
      for (int i=0; i < nr*nc; i++) 
	pchm[i] = NINT(pr[i]);
      ret = octave_value(chm, true);
    }
  else if (pi)
    {
      ComplexMatrix cm(nr, nc);
      Complex *pcm = cm.fortran_vec();
      for (int i=0; i < nr*nc; i++) pcm[i] = Complex(pr[i], pi[i]);
      ret = cm;
    }
  else if (pr)
    {
      Matrix m(nr,nc);
      double *pm = m.fortran_vec();
      memcpy(pm, pr, nr*nc*sizeof(double));
      ret = m;
    }
  else
    ret = Matrix(0,0);

  return ret;
}

/* ========== mex file context ============= */
// Class mex keeps track of all memory allocated and frees anything
// not explicitly marked persistent when the it is destroyed.  It also
// maintains the setjump/longjump buffer required for non-local exit
// from the mex file, and any other state local to this instance of
// the mex function invocation.

class mex {

public:
  mex() { }
  ~mex() { if (!memlist.empty()) error("mex: no cleanup performed"); }

  // free all unmarked pointers obtained from malloc and calloc
  static void cleanup(void* context);

  // allocate a pointer, and mark it to be freed on exit
  Pix malloc(int n);

  // allocate a pointer to be freed on exit, and initialize to 0
  Pix calloc(int n, int t);

  // reallocate a pointer obtained from malloc or calloc
  Pix realloc(Pix ptr, int n);

  // free a pointer obtained from malloc or calloc
  void free(Pix ptr);

  // mark a pointer so that it will not be freed on exit
  void persistent(Pix ptr) { unmark(ptr); }

  // make a new array value and initialize it with zeros; it will be
  // freed on exit unless marked as persistent
  mxArray *make_value(int nr, int nc, int cmplx);

  // make a new array value and initialize from an octave value; it will be
  // freed on exit unless marked as persistent
  mxArray *make_value(const octave_value&);

  // free an array and its contents
  void free_value(mxArray* ptr);

  // mark an array and its contents so it will not be freed on exit
  void persistent(mxArray* ptr);

  // 1 if error should be returned to MEX file, 0 if abort
  int trap_feval_error; 

  // longjmp return point if mexErrMsgTxt or error
  jmp_buf jump;  
  
  // trigger a long jump back to the mex calling function
  void abort() { longjmp(jump, 1); }

private:

  // list of memory resources that need to be freed upon exit
  SLList<Pix> memlist;

  // mark a pointer to be freed on exit
  void mark(Pix p);

  // unmark a pointer to be freed on exit, either because it was
  // made persistent, or because it was already freed
  void unmark(Pix p);

} ;



template class SLList<Pix>;

// free all unmarked pointers obtained from malloc and calloc
void mex::cleanup(Pix ptr)
{
  mex* context = (mex*)ptr;
  for (Pix p = context->memlist.first(); p; context->memlist.next(p))
    ::free(context->memlist(p));
  context->memlist.clear();
}

// XXX FIXME XXX --- could this be added to class SLList<T>?
void del(SLList<Pix>& l, const Pix& v)
{
  if (l.front() == v)
    l.del_front();
  else
    {
      Pix before = l.first();
      Pix p = before;
      l.next(p);
      while (p && l(p) != v) 
	{
	  before = p; l.next(p);
	}
      if (p) l.del_after(before);
    }
}


// mark a pointer to be freed on exit
void mex::mark(Pix p) 
{ 
  if (memlist.owns(p))
    warning("%s: double registration ignored", mexFunctionName);
  else
    memlist.prepend(p);
}

// unmark a pointer to be freed on exit, either because it was
// made persistent, or because it was already freed
void mex::unmark(Pix p) 
{ 
  del(memlist, p);
}

// allocate a pointer, and mark it to be freed on exit
Pix mex::malloc(int n)
{
  if (n == 0) return NULL;
#if 0
  // XXX FIXME XXX --- how do you allocate and free aligned, non-typed
  // memory in C++?
  Pix ptr = Pix(new double[(n+sizeof(double)-1)/sizeof(double)]);
#else
  // XXX FIXME XXX --- can we mix C++ and C-style heap management?
  Pix ptr = ::malloc(n);
  if (ptr == NULL)
    {
      // XXX FIXME XXX --- could use "octave_new_handler();" instead
      error("%s: out of memory", mexFunctionName);
      abort();
    }
#endif
  
  mark(ptr);
  return ptr;
}

// allocate a pointer to be freed on exit, and initialize to 0
Pix mex::calloc(int n, int t)
{
  Pix v = malloc(n*t);
  memset(v, 0, n*t);
  return v;
}

// reallocate a pointer obtained from malloc or calloc
Pix mex::realloc(Pix ptr, int n)
{
#if 0
  error("%s: cannot reallocate using C++ new/delete operations",
	mexFunctionName);
  abort();
#else
  Pix v = NULL;
  if (n == 0) 
    free(ptr);
  else if (ptr == NULL) 
    v = malloc(n);
  else
    {
      v = ::realloc(ptr, n);
      if (v && memlist.owns(ptr))
	{
	  del(memlist, ptr);
	  memlist.prepend(v);
	}
    }
#endif    
  return v;
}

// free a pointer obtained from malloc or calloc
void mex::free(Pix ptr)
{
  unmark(ptr);
#if 0
  delete [] ptr;
#else
  ::free(ptr);
#endif
}


// make a new array value and initialize from an octave value; it will be
// freed on exit unless marked as persistent
mxArray* mex::make_value(const octave_value &ov)
{
  int nr=-1, nc=-1;
  double *pr = NULL, *pi = NULL;

  if (ov.is_numeric_type() || ov.is_string())
    {
      nr = ov.rows();
      nc = ov.columns();
    }
  if (nr > 0 && nc > 0)
    {
      if (ov.is_string())
	{
	  // XXX FIXME XXX - must use 16 bit unicode to represent strings.
	  const Matrix m(ov.matrix_value(1));
	  pr = (double *)malloc(nr*nc*sizeof(double));
	  memcpy(pr, m.data(), nr*nc*sizeof(double));
	}
      else if (ov.is_complex_type())
	{
	  // XXX FIXME XXX --- may want to consider lazy copying of the
	  // matrix, but this will only help if the matrix is being
	  // passed on to octave via callMATLAB later.
	  const ComplexMatrix cm(ov.complex_matrix_value());
	  const Complex * pz = cm.data();
	  pr = (double *)malloc(nr*nc*sizeof(double));
	  pi = (double *)malloc(nr*nc*sizeof(double));
	  for (int i=0; i < nr*nc; i++) 
	    {
	      pr[i] = real(pz[i]);
	      pi[i] = imag(pz[i]);
	    }
	}
      else
	{
	  const Matrix m(ov.matrix_value());
	  pr = (double *)malloc(nr*nc*sizeof(double));
	  memcpy(pr, m.data(), nr*nc*sizeof(double));
	}
    }
  
  mxArray *value = (mxArray*)malloc(sizeof(mxArray));
  value->is_string(ov.is_string());
  value->real(pr);
  value->imag(pi);
  value->rows(nr);
  value->columns(nc);
  value->name("");

  return value;
}

// make a new array value and initialize it with zeros; it will be
// freed on exit unless marked as persistent
mxArray *mex::make_value(int nr, int nc, int cmplx)
{

  mxArray *value = (mxArray*)malloc(sizeof(mxArray));
  double*p = (double*)calloc(nr*nc, sizeof(double));
  value->real(p);
  if (cmplx) value->imag((double*)calloc(nr*nc, sizeof(double)));
  else value->imag((double*)Pix(0));
  value->rows(nr);
  value->columns(nc);
  value->is_string(false);
  value->name("");

  return value;
}

// free an array and its contents
void mex::free_value(mxArray* ptr)
{
  free(ptr->real());
  free(ptr->imag());
  free(ptr);
}

// mark an array and its contents so it will not be freed on exit
void mex::persistent(mxArray* ptr)
{ 
  persistent(Pix(ptr->real()));
  persistent(Pix(ptr->imag()));
  persistent(Pix(ptr));
}


/* ========== Octave interface to mex files ============ */

mex* __mex = NULL;

extern "C" {
  void F77_FUNC(mexfunction,MEXFUNCTION)
    (const int& nargout, mxArray *plhs[], 
     const int& nargin,  mxArray *prhs[]);
  void mexFunction(const int nargout, mxArray *plhs[],
		   const int nargin,  mxArray *prhs[]);
} ;

#if 0 /* Don't bother trapping stop/exit */
// To trap for STOP in fortran code, this needs to be registered with atexit
static void mex_exit()
{
  if (__mex) {
    error("%s: program aborted", mexFunctionName);
    __mex->abort();
  }
}
#endif

enum callstyle { use_fortran, use_C };

octave_value_list 
call_mex(callstyle cs, const octave_value_list& args, const int nargout)
{
#if 0 /* Don't bother trapping stop/exit */
  // XXX FIXME XXX ---- should really push "mex_exit" onto the octave
  // atexit stack before we start and pop it when we are through, but 
  // the stack handle isn't exported from toplev.cc, so we can't.  mex_exit
  // would have to be declared as DEFUN(mex_exit,,,"") of course.
  static bool unregistered = true;
  if (unregistered)
    {
      atexit(mex_exit);
      unregistered = false;
    }
#endif

  // nargout+1 since even for zero specified args, still want to be able
  // to return an ans.
  const int nargin = args.length();
  mxArray * argin[nargin], * argout[nargout+1];
  for (int i=0; i < nargin; i++) argin[i] = NULL;
  for (int i=0; i < nargout+1; i++) argout[i] = NULL;
  
  mex context;
  unwind_protect::add(mex::cleanup, Pix(&context));
		      
  for (int i=0; i < nargin; i++) argin[i] = context.make_value(args(i));

  unwind_protect_ptr(__mex); // save old mex pointer
  if (setjmp(context.jump) == 0)
    {
      __mex = &context;
      if (cs == use_fortran)
	F77_FUNC(mexfunction,MEXFUNCTION)(nargout, argout, nargin, argin);
      else
	mexFunction(nargout, argout, nargin, argin);
    }
  unwind_protect::run(); // restore old mex pointer

  // convert returned array entries back into octave values
  octave_value_list retval;
  if (! error_state)
    {
      for (int i=0; i < nargout+1; i++)
	if (argout[i]) retval(i) = argout[i]->as_octave_value();
      //retval(i) = argout[i] ? argout[i]->as_octave_value() : octave_value();
    }

  unwind_protect::run(); // clean up mex resources
  return retval;
}

octave_value_list 
Fortran_mex(const octave_value_list& args, const int nargout)
{
  return call_mex(use_fortran, args, nargout);
}

octave_value_list 
C_mex(const octave_value_list& args, const int nargout)
{
  return call_mex(use_C, args, nargout);
}

/* ============ C interface to mex functions  =============== */
extern "C" {

  void mexErrMsgTxt (const char *s)
    {
      if (s && strlen(s) > 0) error("%s: %s", mexFunctionName, s);
      else error(""); // just set the error state; don't print msg
      __mex->abort();
    }
  void mexWarnMsgTxt (const char *s)
    {
      warning("%s", s);
    }
  void mexPrintf (const char *fmt, ...)
    {
      va_list args;
      va_start (args, fmt);
      octave_vformat(octave_diary, fmt, args);
      octave_vformat(octave_stdout, fmt, args);
      va_end (args);
    }

  // floating point representation
  int mxIsNaN(const double v) { return xisnan(v) != 0; }
  int mxIsFinite(const double v) { return xfinite(v) != 0; }
  int mxIsInf(const double v) { return xisinf(v) != 0; }
  double mxGetEps() { return DBL_EPSILON; }
  double mxGetInf() { return octave_Inf; }
  double mxGetNaN() { return octave_NaN; }

  int mexEvalString(const char* s)
    {
      int parse_status;
      octave_value_list ret;
      ret = eval_string(s, false, parse_status, 0);
      if ( parse_status || error_state )
	{
	  error_state = 0;
	  return 1;
	}
      else
	return 0;
    }
  int mexCallMATLAB(const int nargout, mxArray* argout[], 
		    const int nargin, const mxArray* argin[],
		    const char* fname)
    {
      octave_value_list args;

      // XXX FIXME XXX --- do we need unwind protect to clean up args?
      // Off hand, I would say that this problem is endemic to Octave
      // and we will continue to have memory leaks after Ctrl-C until
      // proper exception handling is implemented.  longjmp() only
      // clears the stack, so any class which allocates data on the
      // heap is going to leak.
      args.resize(nargin);
      for (int i=0; i < nargin; i++)
	{
	  args(i) = argin[i]->as_octave_value();
	}
      octave_value_list retval = feval(fname, args, nargout);

      if (error_state && __mex->trap_feval_error == 0)
	{
	  // XXX FIXME XXX --- is this the correct way to clean up?
	  // abort() is going to trigger a long jump, so the normal
	  // class destructors will not be called.  Hopefully this
	  // will reduce things to a tiny leak.  Maybe create a new
	  // octave memory tracer type which prints a friendly message
	  // every time it is created/copied/deleted to check this.
	  args.resize(0);
	  retval.resize(0);
	  __mex->abort();
	}

      int num_to_copy = retval.length();
      if (nargout < retval.length()) num_to_copy = nargout;
      for (int i=0; i < num_to_copy; i++)
	{
	  // XXX FIXME XXX --- it would be nice to avoid copying the
	  // value here, but there is no way to steal memory from a
	  // matrix, never mind that matrix memory is allocated
	  // by new[] and mxArray memory is allocated by malloc().
	  argout[i] = __mex->make_value(retval(i));
	}
      while (num_to_copy < nargout) argout[num_to_copy++] = NULL;

      if (error_state)
	{
	  error_state = 0;
	  return 1;
	}
      else
	return 0;
    }

  void mexSetTrapFlag(int flag) { __mex->trap_feval_error = flag;  }

  Pix mxMalloc(int n) { return __mex->malloc(n);  }
  Pix mxCalloc(int n, int size) { return __mex->calloc(n, size); }
  Pix mxRealloc(Pix ptr, int n) { return __mex->realloc(ptr,n); }
  void mxFree(Pix ptr) { __mex->free(ptr); }
  void mexMakeMemoryPersistent(Pix ptr) { __mex->persistent(ptr); }

  mxArray* mxCreateDoubleMatrix(int nr, int nc, int iscomplex)
    {
      return __mex->make_value(nr, nc, iscomplex);
    }
  void mxDestroyArray(mxArray *v) { __mex->free(v);  }
  void mexMakeArrayPersistent(mxArray *ptr) { __mex->persistent(ptr); }

  int mxIsChar (const mxArray* ptr) { return ptr->is_string(); }
  int mxIsSparse (const mxArray* ptr) { return ptr->is_sparse(); }
  int mxIsFull(const mxArray* ptr) { return !ptr->is_sparse(); }
  int mxIsNumeric (const mxArray* ptr) { return ptr->is_numeric(); }
  int mxIsComplex (const mxArray* ptr) { return ptr->is_complex(); }
  int mxIsDouble (const mxArray* ptr) { return true; }
  int mxIsEmpty (const mxArray* ptr) { return ptr->is_empty(); }
  Pix mxGetPr (const mxArray* ptr) { return ptr->real(); }
  Pix mxGetPi (const mxArray* ptr) { return ptr->imag(); }
  int mxGetM (const mxArray* ptr) { return ptr->rows(); }
  int mxGetN (const mxArray* ptr) { return ptr->columns(); }
  void mxSetM (mxArray* ptr, const int M) { return ptr->rows(M); }
  void mxSetN (mxArray* ptr, const int N) { return ptr->columns(N); }
  void mxSetPr (mxArray* ptr, Pix pr) { ptr->real((double *)pr); }
  void mxSetPi (mxArray* ptr, Pix pi) { ptr->imag((double *)pi); }
  double mxGetScalar (const mxArray* ptr)
    {
      double *pr =  ptr->real();
      if (pr) return pr[0];
      else mexErrMsgTxt("calling mxGetScalar on an empty matrix");
    }

  int mxGetString (const mxArray* ptr, char *buf, int buflen)
    {
      if (ptr->is_string())
	{
	  const int nr = ptr->rows();
	  const int nc = ptr->columns();
	  const int n = nr*nc < buflen ? nr*nc : buflen;
	  const double *pr = ptr->real();
	  for (int i = 0; i < n; i++) buf[i] = NINT(pr[i]);
	  if (n < buflen) buf[n] = '\0';
	  return n >= buflen;
	}
      else
	return 1;
    }

  char *mxArrayToString (const mxArray* ptr)
    {
      const int nr = ptr->rows();
      const int nc = ptr->columns();
      const int n = nr*nc*sizeof(mxChar)+1;
      char *buf = (char *)mxMalloc(n);
      if (buf) mxGetString(ptr, buf, n);
      return buf;
    }

  mxArray *mxCreateString(const char *str)
    {
      const int n = strlen(str);
      mxArray *m = __mex->make_value(1, n, 0);
      if (m==NULL) return m;
      m->is_string(true);

      double *pr = m->real();
      for (int i=0; i < n; i++) pr[i] = str[i];
      return m;
    }

  mxArray *mxCreateCharMatrixFromStrings (int n, const char **str)
    {
      // Find length of the individual strings
      Array<int> len(n);
      for (int i=0; i < n; i++) len(i) = strlen(str[i]);

      // Find maximum length
      int maxlen = 0;
      for (int i=0; i < n; i++) if (len(i) > maxlen) maxlen = len(i);

      // Need a place to copy them
      mxArray *m = __mex->make_value(n, maxlen, 0);
      if (m==NULL) return m;
      m->is_string(true);

      // Do the copy (being sure not to exceed the length of any of the
      // strings)
      double *pr = m->real();
      for (int j = 0; j < maxlen; j++)
	for (int i = 0; i < n; i++)
	  if (j < len(i)) *pr++ = str[i][j];
	  else *pr++ = '\0';
      return m;
    }

  int mexPutArray(mxArray *ptr, const char *space)
    {
      if (ptr == NULL) return 1;
      const char *name = ptr->name();
      if (name[0]=='\0') return 1;
      if (strcmp(space,"global") == 0)
	set_global_value (name, ptr->as_octave_value());
      else if (strcmp(space,"caller") == 0)
	{
	  // XXX FIXME XXX --- this belongs in variables.cc
	  symbol_record *sr = curr_sym_tab->lookup (name, true);
	  if (sr) sr->define(ptr->as_octave_value());
	  else panic_impossible ();
	}
      else if (strcmp(space,"base") == 0)
	mexErrMsgTxt("mexPutArray: 'base' symbol table not implemented");
      else
	mexErrMsgTxt("mexPutArray: symbol table does not exist");
	
    }

  mxArray *mexGetArray(const char *name, const char *space)
    {
      // XXX FIXME XXX --- this should be in variable.cc, but the correct
      // functionality is not exported.  Particularly, get_global_value()
      // generates an error if the symbol is undefined.
      symbol_record *sr;
      if (strcmp(space,"global") == 0)
	sr = global_sym_tab->lookup (name);
      else if (strcmp(space,"caller") == 0)
	sr = curr_sym_tab->lookup (name);
      else if (strcmp(space,"base") == 0)
	mexErrMsgTxt("mexGetArray: 'base' symbol table not implemented");
      else
	mexErrMsgTxt("mexGetArray: symbol table does not exist");

      if (sr)
	{
#if defined(HAVE_OCTAVE_20)
	  octave_value sr_def = sr->variable_value();
#else
	  octave_value sr_def = sr->def ();
#endif
	  if (!sr_def.is_undefined ())
	    {
	      mxArray* ptr = __mex->make_value(sr_def);
	      ptr->name(name);
	      return ptr;
	    }
	  else
	    return NULL;
	}
      else
	return NULL;
    }

  mxArray *mexGetArrayPtr(const char *name, const char *space)
    {
      return mexGetArray(name, space);
    }

  const char* mxGetName(const mxArray* ptr)
    {
      return ptr->name();
    }

  void mxSetName(mxArray* ptr, const char*nm)
    {
      ptr->name(nm);
    }

} ;

/* ============ Fortran interface to mex functions ============== */
// Where possible, these call the equivalent C function since that API is
// fixed.  It costs and extra function call, but is easier to maintain.
extern "C" {

  void F77_FUNC(mexerrmsgtxt, MEXERRMSGTXT)
    (const char *s, const int slen)
    {
      if (slen > 1 || (slen == 1 && s[0] != ' ') ) 
	error("%s: %.*s", mexFunctionName, slen, s);
      else error(""); // just set the error state; don't print msg
      __mex->abort();
    }

  void F77_FUNC(mexprintf,MEXPRINTF)
    (const char *s, const int slen)
    {
      mexPrintf("%.*s\n", slen, s);
    }

  double F77_FUNC(mexgeteps,MEXGETEPS)() { return mxGetEps(); }
  double F77_FUNC(mexgetinf,MEXGETINF)() { return mxGetInf(); }
  double F77_FUNC(mexgetnan,MEXGETNAN)() { return mxGetNaN(); }
  int F77_FUNC(mexisfinite,MEXISFINITE)(double v) { return mxIsFinite(v); }
  int F77_FUNC(mexisinf,MEXISINF)(double v) { return mxIsInf(v); }
  int F77_FUNC(mexisnan,MEXISNAN)(double v) { return mxIsNaN(v); }

  // ====> Array access
  Pix F77_FUNC(mxcreatefull,MXCREATEFULL)
    (const int& nr, const int& nc, const int& iscomplex)
    {
      return mxCreateDoubleMatrix(nr,nc,iscomplex);
    }

  void F77_FUNC(mxfreematrix,MXFREEMATRIX)
    (mxArray* &ptr)
    {
      mxDestroyArray(ptr);
    }

  Pix F77_FUNC(mxcalloc,MXCALLOC)(const int& n, const int& size)
    {
      return mxCalloc(n,size);
    }

  void F77_FUNC(mxfree,MXFREE)
    (const Pix &ptr)
    {
      mxFree(ptr);
    }
  
  int F77_FUNC(mxgetm,MXGETM)
    (const mxArray* &ptr) 
    { 
      return mxGetM(ptr); 
    }

  int F77_FUNC(mxgetn,MXGETN)
    (const mxArray* &ptr) 
    { 
      return mxGetN(ptr); 
    }

  Pix F77_FUNC(mxgetpi,MXGETPI)
    (const mxArray* &ptr) 
    {
      return mxGetPi(ptr);
    }

  Pix F77_FUNC(mxgetpr,MXGETPR)
    (const mxArray* &ptr) 
    {
      return mxGetPr(ptr);
    }

  void F77_FUNC(mxsetm,MXSETM)
    (mxArray* &ptr, const int& m) 
    { 
      mxSetM(ptr, m); 
    }

  void F77_FUNC(mxsetn,MXSETN)
    (mxArray* &ptr, const int& n) 
    { 
      mxSetN(ptr, n);
    }

  void F77_FUNC(mxsetpi,MXSETPI)
    (mxArray* &ptr, Pix &pi) 
    {
      mxSetPi(ptr, pi);
    }

  void F77_FUNC(mxsetpr,MXSETPR)
    (mxArray* &ptr, Pix &pr) 
    {
      mxSetPr(ptr, pr);
    }
  
  int F77_FUNC(mxiscomplex,MXISCOMPLEX)
    (const mxArray* &ptr)
    {
      return mxIsComplex(ptr);
    }

  int F77_FUNC(mxisdouble,MXISDOUBLE)
    (const mxArray* &ptr)
    {
      return mxIsDouble(ptr);
    }
  
  int F77_FUNC(mxisnumeric,MXISNUMERIC)
    (const mxArray* &ptr)
    {
      return mxIsNumeric(ptr);
    }
  
  int F77_FUNC(mxisfull,MXISFULL)
    (const mxArray* &ptr)
    {
      return 1 - mxIsSparse(ptr);
    }
  
  int F77_FUNC(mxissparse,MXISSPARSE)
    (const mxArray* &ptr)
    {
      return mxIsSparse(ptr);
    }
  
  int F77_FUNC(mxisstring,MXISSTRING)
    (const mxArray* &ptr)
    {
      return mxIsChar(ptr);
    }

  int F77_FUNC(mxgetstring,MXGETSTRING)
    (const mxArray* &ptr, char *str, const int& len)
    {
      return mxGetString(ptr, str, len);
    }

  int F77_FUNC(mexcallmatlab,MEXCALLMATLAB)
    (const int& nargout, mxArray** argout, 
     const int& nargin, const mxArray** argin,
     const char* fname,
     const int fnamelen)
    {
      char str[mxMAXNAM+1];
      strncpy(str, fname, fnamelen<mxMAXNAM?fnamelen:mxMAXNAM);
      str[fnamelen] = '\0';
      return mexCallMATLAB(nargout, argout, nargin, argin, str);
    }

  // ======> Fake pointer support
  void F77_FUNC(mxcopyreal8toptr,MXCOPYREAL8TOPTR)
    (const double *d, const int& prref, const int& len)
    {
      TRACEFN;
      double *pr = (double *)prref;
      for (int i=0; i < len; i++) pr[i] = d[i];
    }
  
  void F77_FUNC(mxcopyptrtoreal8,MXCOPYPTRTOREAL8)
    (const int& prref, double *d, const int& len)
    {
      TRACEFN;
      double *pr = (double *)prref;
      for (int i=0; i < len; i++) d[i] = pr[i];
    }
  
  void F77_FUNC(mxcopycomplex16toptr,MXCOPYCOMPLEX16TOPTR)
    (const double *d, int& prref, int& piref, const int& len)
    {
      TRACEFN;
      double *pr = (double *)prref;
      double *pi = (double *)piref;
      for (int i=0; i < len; i++) pr[i] = d[2*i], pi[i] = d[2*i+1];
    }
  
  void F77_FUNC(mxcopyptrtocomplex16,MXCOPYPTRTOCOMPLEX16)
    (const int& prref, const int& piref, double *d, const int& len)
    {
      TRACEFN;
      double *pr = (double *)prref;
      double *pi = (double *)piref;
      for (int i=0; i < len; i++) d[2*i]=pr[i], d[2*i+1] = pi[i];
    }
  
} ;
