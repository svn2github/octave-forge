/**************************************************************************
 *  Waitbar function -- displays progress of lengthy calculations
 *  -------------------------------------------------------------
 *  Copyright (c) 2002  Quentin Spencer (qspencer@ieee.org)
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307 USA
 *
 *
 *************************************************************************/

#include <octave/oct.h>
#if defined (HAVE_TERM_H)
#  include <term.h>
#elif defined (HAVE_TERMCAP_H)
#  include <termcap.h>
#endif

#define BUF_SIZE	256
#define MAX_LEN		240
#define DEFAULT_LEN	50
#define	BAR_CHAR	'#'

static bool no_terminal=false;

DEFUN_DLD(waitbar, args, nargout,
"waitbar(...);\n\
 WAITBAR displays a text-based wait bar. This function\n\
 is similar to the Matlab waitbar command, but it is\n\
 a text, rather than graphical function.\n\n\
 A typical usage of WAITBAR in a lengthy computation\n\
 (inside a FOR loop, for example) is as follows:\n\n\
 for i=1:1000\n\
     ## computation\n\
     waitbar(i/1000);\n\
 end\n\n\
 WAITBAR(X), where 0 <= X <= 1, sets the position of the\n\
 waitbar to the fractional length X. Values of X exactly equal\n\
 to 0 or 1 clear the waitbar.\n\n\
 If Octave is running in a smart terminal, the width is\n\
 automatically detected. Otherwise, it is initialized to a\n\
 default of 50 characters, or it can be set to N characters\n\
 with WAITBAR(0,N). If no terminal is detected (such as when\n\
 Octave is run in batch mode and output is redirected), no\n\
 output is generated.\n\n\
 For compatibility with the Matlab version of this function\n\
 (which is graphical rather than text-based), additional\n\
 arguments are ignored, but there are no guarantees of perfect\n\
 compatibility.")
{
  static char print_buf[BUF_SIZE];
  static int n_chars_old;
  static int pct_int_old;
  static int length;
#if defined(USE_TERM)
  static char term_buffer[1024];
  static char *begin_rv, *end_rv;
  static int brvlen, ervlen;
  static bool smart_term;
  int j;
#endif
  static char *term;
  static bool init;

  Matrix arg;
  float pct;
  int i;

  octave_value_list retval;
  int nargin = args.length();
  if (nargin < 1) {
    print_usage("waitbar");
    return retval;
  }

  if(no_terminal)
    return retval;

  arg	= args(0).matrix_value();
  pct	= arg(0,0);
  if(pct>1.0)	pct	= 1.0;		// to prevent overflow

  if(pct==0.0 || pct==1.0)
    {
      init = true;
      term = getenv("TERM");
      if(!term)
	{
	  no_terminal	= true;
	  return retval;
	}
#if defined (USE_TERM)
      i = tgetnum("co");
      smart_term = i ? true : false;
#endif
      if(nargin==1)
#if defined (USE_TERM)
	length = smart_term ? i-1 : DEFAULT_LEN;
#else
        length = DEFAULT_LEN;
#endif
      else
	{
	  length	= args(1).int_value();
	  if(length>MAX_LEN)	length	= MAX_LEN;
	  if(length<=0)		length	= DEFAULT_LEN;
	}
#if defined (USE_TERM)
      if(smart_term)
	{
	  // get terminal strings ("rv"="reverse video")
	  char* buf_ptr	= term_buffer;
	  begin_rv	= tgetstr("so", &buf_ptr);
	  end_rv	= tgetstr("se", &buf_ptr);
	  brvlen = 0;	buf_ptr = begin_rv;
	  while(buf_ptr[++brvlen]);
	  ervlen = 0;	buf_ptr = end_rv;
	  while(buf_ptr[++ervlen]);
	  
	  // initialize print buffer
	  for(i=0; i<BUF_SIZE; ++i)
	    print_buf[i]		= ' ';
	  print_buf[length+brvlen+ervlen+1] = '\r';
	  print_buf[length+brvlen+ervlen+2] = '\0';
	  for(i=0; i<brvlen; ++i)
	    print_buf[i]	= begin_rv[i];
	  for(i=0; i<ervlen; ++i)
	    print_buf[i+brvlen]	= end_rv[i];
	  printf(print_buf);
	}
      else
	{
#endif
	  for(i=0; i<BUF_SIZE; ++i)
	    print_buf[i]		= ' ';
	  print_buf[length+8]	= '\r';
	  print_buf[length+9]	= '\0';
	  printf(print_buf);
	  print_buf[0]		= '[';
	  print_buf[length+1]	= ']';
#if defined (USE_TERM)
	}
#endif
      n_chars_old	= 0;
      fflush(stdout);
      return retval;
    }
  else
    {
      // calculate position
      int n_chars=(int)(pct*length+0.5);
      int pct_int=(int)(pct*100.0+0.5);

      // check to see if we got this far without initialization
      if(init==false)
	{
	  Fwaitbar(octave_value(0.0),0);
	  printf(print_buf);
	  fflush(stdout);
	}

      // check to see of output needs to be updated
      if(n_chars!=n_chars_old || pct_int!=pct_int_old)
	{
#if defined (USE_TERM)
	  if(smart_term)
	    {
	      static char pct_str[6];
	      int half = length/2-1;
	      sprintf(pct_str,"%3i%%%%",pct_int);

	      // Clear old percentage string
	      for(i=half, j=0; j<5; ++i, ++j)
		if(i>=n_chars_old)
		  print_buf[i+brvlen+ervlen]	= ' ';
		else
		  print_buf[i+brvlen]	= ' ';

	      // Clear old and insert new end of reverse video
	      for(i=n_chars_old+brvlen; i<n_chars_old+brvlen+ervlen; ++i)
		print_buf[i]	= ' ';
	      for(i=n_chars+brvlen, j=0; j<ervlen; ++i, ++j)
		print_buf[i]	= end_rv[j];

	      // Insert the percentage string
	      for(i=half, j=0; j<5; ++i, ++j)
		if(i>=n_chars)
		  print_buf[i+brvlen+ervlen]	= pct_str[j];
		else
		  print_buf[i+brvlen]	= pct_str[j];
	    }
	  else
	    {
#endif
	      if(n_chars>=n_chars_old)
		for(int i=n_chars_old+1; i<=n_chars; ++i)
		  print_buf[i]	= BAR_CHAR;
	      else
		for(int i=n_chars+1; i<=n_chars_old; ++i)
		  print_buf[i]	= ' ';
	      sprintf(&(print_buf[length+3])," %3i%%\r",pct_int);
#if defined (USE_TERM)
	    }
#endif
	  printf(print_buf);
	  fflush(stdout);
	  n_chars_old	= n_chars;
	  pct_int_old	= pct_int;
	}
    }
  return retval;
}
