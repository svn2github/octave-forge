/* Copyright (C) 2004 Stefan van der Walt <stefan@sun.ac.za>

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#include <octave/oct.h>
#include <pcre.h>
#include <iostream>

DEFUN_DLD( pcregexp, args, nargout, "\
Perl-compatible regular expression matching.\n\
\n\
See also \"help regexp\" and the manpage for 'pcre'.\n\
" ) {

    octave_value_list retval = octave_value_list();

    if (args.length() != 2) {
	print_usage("pcregexp");
	return retval;
    }

    std::string pattern = args(0).string_value();
    std::string input = args(1).string_value();
    if (error_state) {
	gripe_wrong_type_arg("pcregexp", args(0));
	return retval;
    }

    // Compile expression
    pcre *re;
    const char *err;
    int erroffset;
    re = pcre_compile(pattern.c_str(), 0, &err, &erroffset, NULL);
    
    if (re == NULL) {
	error("pcregexp: %s at position %d of expression", err, erroffset);
	return retval;
    }

    // Get nr of subpatterns
    int subpatterns;
    int status = pcre_fullinfo(re, NULL, PCRE_INFO_CAPTURECOUNT, &subpatterns);

    // Match expression
    int ovector[(subpatterns+1)*3];
    int matches = pcre_exec(re, NULL, input.c_str(), input.length(), 0, 0, ovector, (subpatterns+1)*3);

    if (matches == PCRE_ERROR_NOMATCH) {
    	retval = octave_value_list(Matrix());
	for (int i = 1; i < nargout; i++) {
	    retval(i) = "";
	}
	pcre_free(re);
    	return retval;
    } else if (matches < -1) {
	error("pcregexp: internal error calling pcre_exec");
	return retval;
    }

    const char **listptr;
    status = pcre_get_substring_list(input.c_str(), ovector, matches, &listptr);

    if (status == PCRE_ERROR_NOMEMORY) {
	error("pcregexp: cannot allocate memory in pcre_get_substring_list");
	pcre_free(re);
	return retval;
    }

    // Pack indeces
    Matrix indeces = Matrix(matches, 2);
    for (int i = 0; i < matches; i++) {
	indeces(i, 0) = ovector[2*i]+1;
	indeces(i, 1) = ovector[2*i+1];
	if (indeces(i, 0) == 0) indeces(i, 1) = 0;
    }
    retval(0) = indeces;

    // Pack substrings
    retval.resize(nargout + 1);
    for (int i = 0; i < matches; i++) {
	retval(i+1) = *(listptr+i+1);
    }

    // Free memory
    pcre_free_substring_list(listptr);
    pcre_free(re);

    if (nargout > matches) {
	error("pcregexp: too many return values requested");
	return octave_value_list();
    }

    return retval;
}

/*
%!assert(pcregexp("f(.*)uck"," firetruck "),[2,10;3,7]);
%!test
%! [m,b]=pcregexp("f(.*)uck"," firetruck ");
%! assert(m,[2,10;3,7]);
%! assert(b, "iretr")
%!test
%! [m,b] = pcregexp("a(.*?)d", "asd asd");
%! assert(m, [1,3;2,2]);
%! assert(b, "s");
%!test
%! [m,b] = pcregexp("a", "A");
%! assert(isempty(m))
%! assert(b, "")
%!fail("[m,b] = pcregexp('a', 'a')", "pcregexp")
%!fail("pcregexp('(', '')", "pcregexp")
%!

%!demo
%! [m, s1] = pcregexp("(a.*?(d))", "asd asd")
*/
