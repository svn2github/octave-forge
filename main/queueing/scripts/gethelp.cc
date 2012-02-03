/*

Copyright (C) 1999, 2000, 2003, 2007 John W. Eaton
Copyright (C) 2011 Moreno Marzolla

This file is part of the queueing toolbox.

The queueing toolbox is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 3 of the
License, or (at your option) any later version.

The queueing toolbox is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#if defined (__DECCXX)
#define __USE_STD_IOSTREAM
#endif

#include <string>
#include <iostream>
#include <cstdio>

#ifndef NPOS
#define NPOS std::string::npos
#endif

static bool
looks_like_octave_copyright (const std::string& s)
{
  // Perhaps someday we will want to do more here, so leave this as a
  // separate function.

  return (s.substr (0, 9) == "Copyright");
}

// Eat whitespace and comments from FFILE, returning the text of the
// first block of comments that doesn't look like a copyright notice,

static std::string
extract_help_text (void)
{
  std::string help_txt;

  bool first_comments_seen = false;
  bool begin_comment = false;
  bool have_help_text = false;
  bool in_comment = false;
  bool discard_space = true;
  int c;

  while ((c = std::cin.get ()) != EOF)
    {
      if (begin_comment)
	{
	  if (c == '%' || c == '#')
	    continue;
	  else if (discard_space && c == ' ')
	    {
	      discard_space = false;
	      continue;
	    }
	  else
	    begin_comment = false;
	}

      if (in_comment)
	{
	  if (! have_help_text)
	    {
	      first_comments_seen = true;
	      help_txt += (char) c;
	    }

	  if (c == '\n')
	    {
	      in_comment = false;
	      discard_space = true;

	      if ((c = std::cin.get ()) != EOF)
		{
		  if (c == '\n')
		    break;
		}
	      else
		break;
	    }
	}
      else
	{
	  switch (c)
	    {
	    case ' ':
	    case '\t':
	      if (first_comments_seen)
		have_help_text = true;
	      break;

	    case '\n':
	      if (first_comments_seen)
		have_help_text = true;
	      continue;

	    case '%':
	    case '#':
	      begin_comment = true;
	      in_comment = true;
	      break;

	    default:
	      goto done;
	    }
	}
    }

 done:

  if (! help_txt.empty ())
    {
      if (looks_like_octave_copyright (help_txt)) 
	help_txt.resize (0);

      if (help_txt.empty ())
	help_txt = extract_help_text ();
    }

  return help_txt;
}

int
main (int argc, char **argv)
{
  std::string name;

  if (argc != 2)
    {
      std::cerr << "usage: gethelp name\n";
      return 1;
    }
  else
    name = argv[1];

  std::string help_text = extract_help_text ();  

  if (! help_text.empty ())
    {
      std::cout << "" << name << "\n" << help_text;

      if (help_text[help_text.length () - 1] != '\n')
	std::cout << "\n";
    }

  return 0;
}
