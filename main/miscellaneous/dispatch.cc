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
static const std::string ALIAS_KEYWORD("any");

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
  void clear (const std::string t);
  void print (std::ostream& os, bool pr_as_read=false) const;

private:

  Table tab;
  std::string base;
  bool has_alias;

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
  : octave_function (), tab (), base(), has_alias(false)
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
  if (t==ALIAS_KEYWORD) has_alias=true;
}
void
octave_dispatch::clear (const std::string t)
{
  tab.erase(t); 
  if (t==ALIAS_KEYWORD) has_alias=false;
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

static octave_function*
builtin(const std::string& base)
{
  octave_function *fcn = NULL;

  // Check if we are overriding a builtin function.  This is the
  // case if builtin is protected.
  symbol_record* builtin=fbi_sym_tab->lookup("builtin:"+base,0);
  if (builtin==NULL) error("builtin record has gone missing");
  if (error_state) return fcn;

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
      fbi_sym_tab->rename (base, "dispatch:"+base);
      fbi_sym_tab->rename ("builtin:"+base, base);

      // check for updates to builtin function; ignore errors that
      // appear (they interfere with renaming), and remove the updated
      // name from the current symbol table.  XXX FIXME XXX check that
      // updating a function updates it in all contexts --- it may be
      // that it is updated only in the current symbol table, and not
      // the caller.  I believe this won't be a problem because the
      // caller will go through the same logic and end up with the
      // newer version.
      fcn = is_valid_function (base, "dispatch", 1);
      int cache_error = error_state; error_state = 0;
      curr_sym_tab->clear_function(base);

      // Move the builtin function out of the way and restore the
      // dispatch fuction.
      // XXX FIXME XXX what if builtin wants to protect itself?
      symbol_record* found=fbi_sym_tab->lookup(base,0);
      bool readonly=found->is_read_only();
      found->unprotect();
      fbi_sym_tab->rename (base, "builtin:"+base);
      fbi_sym_tab->rename ("dispatch:"+base, base);
      if (readonly) found->protect();
      dispatch->protect();

      // remember if there were any errors.
      error_state = cache_error;
    }

  return fcn;
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
  // overloaded functions.  Also provide a catch-all '*' type to provide
  // single level pseudo rename and replace functionality.
  if (args.length() > 0 && tab.count (args(0).type_name()) > 0)
    retval = feval (tab[args(0).type_name()], args, nargout);
  else if (has_alias)
    retval = feval (tab[ALIAS_KEYWORD], args, nargout);
  else
    {
      octave_function *fcn = builtin (base);
      if (!error_state && fcn != NULL)
        retval = fcn->do_multi_index_op (nargout, args);
    }
  return retval;
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
      symbol_record* sr = fbi_sym_tab->lookup(name,0);
      if (sr->def().type_id() == octave_dispatch::static_type_id()) {
        octave_function *fcn = builtin (name);
        if (!error_state && fcn != NULL)
          retval = fcn->do_multi_index_op (nargout, args.splice(0,1,retval));
      } else {
	retval = feval(name,args,nargout);
      }
    }
  else
    print_usage ("builtin");
  return retval;
}

// octave_function* builtin_help = NULL;
DEFUN_DLD(dispatch_help, args, nargout, "\
Delayed loading of help messages for dispatched functions.")
{
  octave_value_list retval;
  int nargin = args.length();
  for (int i=0; i < nargin; i++) {
    if (args(i).is_string()) {
      const std::string name(args(i).string_value());
      if (error_state) return retval;
      symbol_record* sr = fbi_sym_tab->lookup(name,false);
      if (sr) {
        std::string help = sr->help();
        if (help[0]=='<' && help[1]=='>'
	    && sr->def().type_id() == octave_dispatch::static_type_id()) {
	  builtin(name);
	  symbol_record* builtin_record=fbi_sym_tab->lookup("builtin:"+name,0);
	  help.replace(0,2,builtin_record->help());
	  sr->document(help);
        }
      }
    }
  }
  return feval("builtin:help",args,nargout);
}

static void
dispatch_record(const std::string &f, const std::string &n, 
	        const std::string &t)
{
  // find the base function in the symbol table, loading it if it
  // is not already there; if it is already a dispatch, then bonus
  symbol_record *sr = fbi_sym_tab->lookup(f,true);
  if (sr->def().type_id() != octave_dispatch::static_type_id())
    {
      // Not an overloaded name, so if only display or clear then we are done
      if ( t.empty() ) return;

      // sr is the base symbol; rename it to keep it safe.  When we need
      // it we will rename it back again.
      if (sr->is_read_only()) 
        {
          sr->unprotect();
          fbi_sym_tab->rename (f, "builtin:"+f);
  	  sr = fbi_sym_tab->lookup(f,true);
          sr->protect();
	}
      else 
        fbi_sym_tab->rename (f, "builtin:"+f);
      std::string basedoc("<>"); 
      if (!sr->help().empty()) basedoc=sr->help();

      // Problem:  when a function is first called a new record
      // is created for it in the current symbol table, so calling
      // dispatch on a function that has already been called, we
      // should also clear it from all existing symbol tables.
      // This is too much work, so we will only do it for the
      // top level symbol table.  We can't use the clear_function() 
      // method, because it won't clear builtin functions.  Instead 
      // we check if the symbol is a function and clear it then.  This
      // won't properly clear shadowed functions, or functions in
      // other namespaces (such as the current, if called from a
      // function).
      symbol_record *local;
      local = top_level_sym_tab->lookup(f,false);
      if (local && local->is_function()) local->clear(); 

      // Build a new dispatch object based on the function definition
      octave_dispatch *dispatch = new octave_dispatch(f);
  
      // Create a symbol record for the dispatch object.
      sr = fbi_sym_tab->lookup(f,true);
      sr->unprotect();
      // XXX FIXME XXX TEXT_FUNCTION was renamed to COMMAND == 16
      sr->define(octave_value(dispatch),
			     symbol_record::BUILTIN_FUNCTION|16); 
      sr->document(basedoc + "\n\nOverloaded function\n");
      sr->make_eternal(); // XXX FIXME XXX why??
      sr->mark_as_static();
      sr->protect();
    }

  // clear/replace/extend the map with the new type-function pair
  const octave_dispatch& rep = (octave_dispatch&)(sr->def().get_rep());
  if (t.empty ())
    // XXX FIXME XXX should return the list if nargout > 1
    ((octave_dispatch&) rep) . print (octave_stdout);
  else if (n.empty ())
    // XXX FIXME XXX should we eliminate the dispatch function if
    // there are no more elements?
    // XXX FIXME XXX should clear the " $t:\w+" from the help string.
    ((octave_dispatch&) rep) . clear (t);
  else {
    ((octave_dispatch&) rep) . add (t,n);
    if (!sr->help().empty()) sr->document(sr->help()+"\n   "+n+"("+t+",...)");
  }
}

/*
%!test # builtin function replacement
%! dispatch('sin','length','string')
%! assert(sin('abc'),3)
%! assert(sin(0),0,10*eps); 
%!test # 'any' function
%! dispatch('sin','exp','any')
%! assert(sin(0),1,eps);
%! assert(sin('abc'),3);
%!test # 'builtin' function
%! assert(builtin('sin',0),0,eps);
%! builtin('eval','x=1;');
%! assert(x,1);
%!test # clear function mapping
%! dispatch('sin','string')
%! dispatch('sin','any')
%! assert(sin(0),0,10*eps);
%!test # oct-file replacement
%! dispatch('fft','length','string')
%! assert(fft([1,1]),[2,0]);
%! assert(fft('abc'),3)
%! dispatch('fft','string');
%!test # m-file replacement
%! dispatch('hamming','length','string')
%! assert(hamming(1),1)
%! assert(hamming('abc'),3)
%! dispatch('hamming','string')

%!test # override preloaded builtin
%! evalin('base','cos(1);');
%! dispatch('cos','length','string')
%! evalin('base',"assert(cos('abc'),3)");
%! evalin('base',"assert(cos(0),1,eps)");
%! dispatch('cos','string')
%!test # override pre-loaded oct-file
%! evalin('base','qr(1);');
%! dispatch('qr','length','string')
%! evalin('base',"assert(qr('abc'),3)");
%! evalin('base',"assert(qr(1),1)");
%! dispatch('qr','string');
%!test # override pre-loaded m-file
%! evalin('base','hanning(1);');
%! dispatch('hanning','length','string')
%! evalin('base','assert(hanning("abc"),3)');
%! evalin('base','assert(hanning(1),1)');
%! dispatch('hanning','string');

XXX FIXME XXX I would rather not create dispatch_x/dispatch_y
in the current directory!  I don't want them installed accidentally.

%!test # replace base m-file
%! system("echo 'function a=dispatch_x(a)'>dispatch_x.m");
%! dispatch('dispatch_x','length','string')
%! assert(dispatch_x(3),3)
%! assert(dispatch_x('a'),1)
%! pause(1);
%! system("echo 'function a=dispatch_x(a),++a;'>dispatch_x.m");
%! assert(dispatch_x(3),4)
%! assert(dispatch_x('a'),1)
%!test 
%! system("rm dispatch_x.m");

%!test # replace dispatch m-file
%! system("echo 'function a=dispatch_y(a)'>dispatch_y.m");
%! dispatch('hello','dispatch_y','complex scalar')
%! assert(hello(3i),3i)
%! pause(1);
%! system("echo 'function a=dispatch_y(a),++a;'>dispatch_y.m");
%! assert(hello(3i),1+3i)
%!test 
%! system("rm dispatch_y.m");
*/

DEFUN_DLD(dispatch, args, , "\
dispatch('f','r','type')\n\
\n\
  Replaces the function 'f' with a dispatch so that function 'r'\n\
  is called when 'f' is called with the first argument of the named\n\
  type. If the type is 'any' then call 'r' if no other type  matches.\n\
  The original function 'f' is accessible using builtin('f',...).\n\
\n\
dispatch('f','type')\n\
\n\
  Clear dispatch function associated with the given type.\n\
\n\
dispatch('f')\n\
\n\
  List dispatch functions for 'f'\n\
\n\
See also: builtin") 
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
      dispatch_record("help","dispatch_help","string");
    }

  dispatch_record(f,n,t);

  return retval;
}


#if defined(__GNUG__)
template class std::map<std::string,std::string>;
#endif
