// mkoctfile-2.1.40 dispatch.cc -DOCTAVE_FUNCTION_VOID_FAILS -DHAVE_SLLIST_H
// mkoctfile-2.1.57 dispatch.cc -DTYPEID_HAS_CLASS

/*

Copyright (C) 2001 John W. Eaton

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

2001-11-20 Paul Kienzle
* bring various bits of ov-builtin, ov-fcn, symtab, variables together
  to create this new file containing the new octave_dispatch type.
*/

#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/variables.h>
#include <octave/symtab.h>
#include <octave/pager.h>
#include <string>
#include <map>
#ifdef HAVE_SLLIST_H
#define LIST SLList
#define LISTSIZE length
#define SUBSREF_STRREF
#else
#include <list>
#define LIST std::list
#define LISTSIZE size
#define SUBSREF_STRREF &
#endif

using std::cin;
using std::cout;
using std::endl;

// XXX FIXME XXX should be using a map from type_id->name, rather
// than type_name->name
typedef std::map<std::string,std::string> Table;

class
octave_dispatch : public octave_function
{
public:

  // XXX FIXME XXX need to handle doc strings of dispatched functions, for
  // example, by appending "for <f>(<type>,...) see <name>" for each
  // time dispatch(f,type,name) is called.
  octave_dispatch (const std::string& s);

  // XXX FIXME XXX if we get deleted, we should restore the original
  // symbol_record from base before dying.
  ~octave_dispatch (void) { }

  bool is_builtin_function (void) const { return true; }
  octave_function *function_value (bool) { return this; }
  octave_value
  do_index_op (const octave_value_list&, int)
  {
    error("dispatch: do_index_op");
    return octave_value ();
  }
  octave_value subsref (const std::string SUBSREF_STRREF type,
			const LIST<octave_value_list>& idx)
  {
    error("dispatch: subsref(str,list)");
    panic_impossible ();
    return octave_value ();
  }

  octave_value_list subsref (const std::string SUBSREF_STRREF type,
			     const LIST<octave_value_list>& idx,
			     int nargout);
  octave_value_list do_multi_index_op (int, const octave_value_list&);

  void add (const std::string t, const std::string n);
  void clear (const std::string t) { tab.erase(t); }
  void print (std::ostream& os, bool pr_as_read=false) const;

private:

  Table tab;
  std::string base;

#ifndef OCTAVE_FUNCTION_VOID_FAILS
  octave_dispatch (void);
#endif

  octave_dispatch (const octave_dispatch& m);

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

  DECLARE_OCTAVE_ALLOCATOR
};

DEFINE_OCTAVE_ALLOCATOR (octave_dispatch);

#ifdef TYPEID_HAS_CLASS
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_dispatch, "overloaded function","function");
#else
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_dispatch, "overloaded function");
#endif


#ifndef OCTAVE_FUNCTION_VOID_FAILS
octave_dispatch::octave_dispatch (void) 
  : octave_function (), tab (), base() 
{ }
#endif

octave_dispatch::octave_dispatch (const std::string &name)
  : octave_function (name, "Overloaded function"), tab (), base(name) 
{ }

void 
octave_dispatch::add (const std::string t, const std::string n)
{ 
  if (tab.count(t) > 0 && tab[t] != n)
    warning("replacing %s(%s,...)->%s with %s",
	    base.c_str(), t.c_str(), tab[t].c_str(), n.c_str());
  tab[t] = n; 
}

octave_value_list
octave_dispatch::subsref (const std::string SUBSREF_STRREF type,
			const LIST<octave_value_list>& idx,
			int nargout)
{
  octave_value_list retval;

  switch (type[0])
    {
    case '(':
      retval = do_multi_index_op (nargout, idx.front ());
      break;

    case '{':
    case '.':
      {
	const std::string nm = type_name ();
	error ("%s cannot be indexed with %c", nm.c_str (), type[0]);
      }
      break;

    default:
      panic_impossible ();
    }

  if (idx.LISTSIZE () > 1)
    retval = retval(0).next_subsref (type, idx);

  return retval;
}

static octave_value_list
builtin(const std::string& base, octave_value_list args, int nargout)
{
  octave_value_list retval;

  // Check if we are overriding a builtin function.  This is the
  // case if builtin is protected.
  symbol_record* builtin=fbi_sym_tab->lookup("builtin#"+base,0);
  if (builtin==NULL) error("builtin record has gone missing");
  if (error_state) return retval;

  octave_function *fcn;
  if (builtin->is_read_only())
    {
      // builtin is read only, so checking for updates is pointless
      if (builtin->is_function())
        fcn = builtin->def().function_value();
      else
	error("builtin %s is not a function",base.c_str());
    }
  else
    {
      // Check that builtin is up to date.
 
      // Don't try to fight octave's function name handling
      // mechanism.  Instead, move dispatch record out of the way,
      // and restore the builtin to its original name.
      symbol_record* dispatch=fbi_sym_tab->lookup(base,0);
      if (dispatch==NULL) error("dispatch record has gone missing");
      dispatch->unprotect();
      fbi_sym_tab->rename (base, "dispatch#"+base);
      fbi_sym_tab->rename ("builtin#"+base, base);

      // check for updates to builtin function; ignore errors that
      // appear (they interfere with renaming), and remove the updated
      // name from the current symbol table.
      fcn = is_valid_function (base, "dispatch", 1);
      int cache_error = error_state; error_state = 0;
      curr_sym_tab->clear_function(base);

      // Move the builtin function out of the way and restore the
      // dispatch fuction.
      // XXX FIXME XXX what if builtin wants to protect itself?
      symbol_record* found=fbi_sym_tab->lookup(base,0);
      bool readonly=found->is_read_only();
      found->unprotect();
      fbi_sym_tab->rename (base, "builtin#"+base);
      fbi_sym_tab->rename ("dispatch#"+base, base);
      if (readonly) found->protect();
      dispatch->protect();

      // remember if there were any errors.
      error_state = cache_error;
    }

  // Call the function if it is valid
  if (!error_state && fcn != NULL) 
    return fcn->do_multi_index_op (nargout, args);
  else 
    return octave_value_list();
}

static bool
any_arg_is_magic_colon (const octave_value_list& args)
{
  int nargin = args.length ();

  for (int i = 0; i < nargin; i++)
    if (args(i).is_magic_colon ())
      return true;

  return false;
}


octave_value_list
octave_dispatch::do_multi_index_op (int nargout, const octave_value_list& args)
{
  octave_value_list retval;

  if (error_state) return retval;

  if (any_arg_is_magic_colon (args)) {
    ::error ("invalid use of colon in function argument list");
    return retval;
  }

  // If more than one argument, check if argument template matches any
  // overloaded functions.
  if (args.length() > 0 && tab.count (args(0).type_name()) > 0)
    return feval (tab[args(0).type_name()], args, nargout);
  else
	return builtin (base, args, nargout);
}

void 
octave_dispatch::print (std::ostream& os, bool pr_as_read) const
{
  octave_stdout << "Overloaded function " << base << std::endl;
  for (Table::const_iterator it = tab.begin(); it != tab.end(); it++)
    {
      octave_stdout << base << "(" << it->first << ",...)->" 
	     << it->second << "(" << it->first << ",...)" << std::endl;
    }
}


DEFUN_DLD(builtin, args, nargout, "\
[out] = builtin('f',args)\n\
\n\
Call the base function 'f' even if 'f' is overloaded to\n\
some other function for the given type signature.")
{
  octave_value_list retval; 
  int nargin = args.length();
  if (nargin > 0)
    {
      const std::string name(args(0).string_value());
	  if (error_state) return retval;
	  retval = builtin(name,args.splice(0,1,retval), nargout);
	}
  else
    print_usage ("builtin");
  return retval;
}

DEFUN_DLD(dispatch, args, , "\
dispatch('f','name','type')\n\
\n\
Replaces the symbol for the name f with a dispatch\n\
function so that if f is called with the first argument\n\
of the given type, then all arguments are passed to\n\
the named alternative function instead.\n\
\n\
dispatch('f','type')\n\
\n\
Clear dispatch function associated with the given type\n\
\n\
dispatch('f')\n\
\n\
List dispatch functions\n\
") 
{
  octave_value retval;
  int nargin = args.length();

  if (nargin < 1 || nargin > 3)
    {
      print_usage("dispatch");
      return retval;
    }

  std::string f,t,n;
  if (nargin > 0) f = args(0).string_value();
  if (nargin == 2)
    t = args(1).string_value();
  else if (nargin > 2) {
    n = args(1).string_value();
    t = args(2).string_value();
  }

  if (error_state) return retval;
  
  static bool register_type = true;

  // register dispatch function type if you have not already done so
  if (register_type)
    {
      octave_dispatch::register_type ();
      register_type = false;
      fbi_sym_tab->lookup("dispatch")->mark_as_static();
    }

  // find the base function in the symbol table, loading it if it
  // is not already there; if it is already a dispatch, then bonus
  symbol_record *sr = fbi_sym_tab->lookup(f,true);
  if (sr->def().type_id() != octave_dispatch::static_type_id())
    {
      // Not an overloaded name, so if display or clear then we are done
      if ( nargin < 3) return retval;

      // sr is the base symbol; rename it to keep it safe.  When we need
      // it we will rename it back again.
      if (sr->is_read_only()) 
        {
          sr->unprotect();
          fbi_sym_tab->rename (f, "builtin#"+f);
          sr->protect();
	}
      else 
        fbi_sym_tab->rename (f, "builtin#"+f);
      
      // Build a new dispatch object based on the function definition
      octave_dispatch *dispatch = new octave_dispatch(f);
  
      // Create a symbol record for the dispatch object.
      sr = fbi_sym_tab->lookup(f,true);
      sr->unprotect();
      sr->define(octave_value(dispatch),
			     symbol_record::BUILTIN_FUNCTION|16); 
// XXX FIXME XXX TEXT_FUNCTION was renamed to COMMAND == 16
      sr->document("Overloaded function\n"); // XXX FIXME XXX this
      sr->make_eternal(); // XXX FIXME XXX why??
      sr->mark_as_static();
      sr->protect();
    }
  
  // clear/replace/extend the map with the new type-function pair
  const octave_dispatch& rep = (octave_dispatch&)(sr->def().get_rep());
  if (nargin == 1)
    ((octave_dispatch&) rep) . print (octave_stdout);
  else if (nargin == 2)
    // XXX FIXME XXX should we eliminate the dispatch function if
    // there are no more elements?
    // XXX FIXME XXX should clear the " $t:\w+" from the help string.
    ((octave_dispatch&) rep) . clear (t);
  else {
    ((octave_dispatch&) rep) . add (t,n);
    sr->document(sr->help()+"\n   "+n+"("+t+",...)");
  }

  return retval;
}


#if defined(__GNUG__)
template class std::map<std::string,std::string>;
#endif
