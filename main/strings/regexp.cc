/*
Author: Paul Kienzle <pkienzle@users.sf.net>

This program is granted to the public domain

2002-01-15 Paul Kienzle <pkienzle@users.sf.net>
* Initial revision

*/

#include <octave/oct.h>
#include <regex.h>

DEFUN_DLD(regexp,args,nargout,"\
Regular expression string matching.\n\
match = regexp(pattern,string)\n\
   Returns the start and end indices of the matching substring, or the\n\
   or the empty matrix if there is none.  There is one additional row\n\
   for each set of parentheses in the pattern indicating the start and\n\
   end index for the first match for that subexpression.  So the\n\
   expression string(match(2,1):match(2,2)) will return the string\n\
   matched by the first set of parentheses.  Note that parentheses\n\
   within ( exp1 | exp2 | ...  ) are not counted.\n\
[match s1 s2 ...] = regexp(pattern,string)\n\
   Returns the matching substrings in s1, s2, etc.\n\
   If there is no match then empty strings are returned.\n\
\n\
Uses the POSIX extended matching routine regcomp.  See your local manpages\n\
for details.\n\
")
{
  octave_value_list retval;
  int nargin = args.length();

  if (nargin != 2)
    {
      print_usage("regexp");
      return retval;
    }

  std::string pattern = args(0).string_value ();
  if (error_state)
    {
      gripe_wrong_type_arg ("regexp", args(0));
      return retval;
    }

  std::string buffer = args(1).string_value ();
  if (error_state)
    {
      gripe_wrong_type_arg ("regexp", args(1));
      return retval;
    }

  regex_t compiled;
  int err=regcomp(&compiled, pattern.c_str(), REG_EXTENDED);
  if (err)
    {
      int len = regerror(err, &compiled, NULL, 0);
      char *errmsg = (char *)malloc(len);
      if (errmsg)
	{
	   regerror(err, &compiled, errmsg, len);
	   error("regexp: %s in pattern (%s)", errmsg, pattern.c_str());
           free(errmsg);
        }
      else
        {
           error("out of memory");
        }
      regfree(&compiled);
      return retval;
    }

  // allocate space for the matches
  int subexpr = 1;
  for (unsigned int i=0; i < pattern.length(); i++)
    {
      subexpr += ( pattern[i] == '(' ? 1 : 0 );
    }
  OCTAVE_LOCAL_BUFFER (regmatch_t, match, subexpr );

  // do the match
  if (regexec(&compiled, buffer.c_str(), subexpr, match, 0)==0) 
    {
      // Count actual matches (this may be less than the number of
      // parentheses if there are parentheses inside of ( ... | ... )
      int matches = 0;
      while (matches < subexpr && match[matches].rm_so >= 0) matches++;
      if (nargout > matches)
        {
	  error("regexp: too many return values requested");
	  return retval;
        }

      // Allocate space for the return values
      if (nargout == 0) nargout = 1;
      retval.resize(nargout);

      // Copy the match indices to retval(0)
      Matrix indices(matches,2);
      for (int i=0 ; i < subexpr && match[i].rm_so >= 0; i++)
	indices(i,0) = match[i].rm_so+1, indices(i,1) = match[i].rm_eo;
      retval(0) = indices;

      // Copy the substrings to the output arguments
      for (int i=1 ; i < nargout && match[i].rm_so >= 0; i++)
	retval(i) = buffer.substr(match[i].rm_so,match[i].rm_eo-match[i].rm_so);
    }
  else
    {
      for (int i=nargout-1; i > 0; i--) retval(i) = "";
      retval(0) = Matrix(0,0);
    }

  regfree(&compiled);
  
  return retval;
}
