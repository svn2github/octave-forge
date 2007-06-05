/*

Copyright (C) 2007 David Bateman

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

*/


// These are the language specific parts of this file that need changing

// Language file extension. For example .fr for french, .pt or portuguese
// or .pt_BR for Brazilian
#define LANG_EXT ".en"

// Function name, both with and without the quotes. This should match the
// file name that is chosen for the help function.
#define HELP_NAME help
#define HELP_STRING "help"

// The final word in the following PKG_ADD command should match the above
// PKG_ADD: mark_as_command help

// The texinfo formatted help message for the function. Please be careful
// that accented characters respect texinfo formatting
#define HELP_TEXT  \
 "@deftypefn {Command} {} help @var{topic}\n\
  @deftypefnx {Loadable Function} {} help (@var{topic})\n\
  Help function for English.\n"

// Some additional non texinfo formatted message 
#define NOT_FOUND "not found" 
#define NOT_DOCUMENTED "is not documented"
#define MD5_MISMATCH "MD5 mismatch in translated string.\nUse `help' to obtain original help string"
#define TEXINFO_ERROR_1 "Texinfo formatting filter exited abnormally"
#define TEXINFO_ERROR_2 "raw Texinfo source of help text follows..."

// Additional help message.
#define ADDITIONAL_HELP \
"Additional help for built-in functions and operators is\n\
available in the on-line version of the manual.  Use the command\n\
`doc <topic>' to search the manual index.\n\
\n\
Help and information about Octave is also available on the WWW\n\
at http://www.octave.org and via the help@octave.org\n\
mailing list.\n"

// Language specific macros and seealso macro
#define MAKEINFO_MACROS \
"@documentencoding ISO-8859-1\n\
@set cedilha @,{c}\n\
@set o_til @~o\n\
@macro seealso {args}\n\
@sp 1\n\
@noindent\n\
See also: \\args\\.\n\
@end macro\n"

// Below is a bit of magic that allows the indexing script to correctly
// find the function and the help text. Yes it is supposed to be commented,
// and whether the indexing script finds the macros correctly is very sensitive
// to the formatting (leave the dummy comment). Please note that DEFUN_DLD 
// must appear on a newline. The first argument name needs to be the same 
// as HELP_NAME
/*
DEFUN_DLD_DUMMY (help, 
"-*- texinfo -*-\n" 
MAKEINFO_MACROS
"@c dummy comment\n"
HELP_TEXT
"@seealso{help, doc}\n\
@end deftypefn")
*/

// This includes the part of the function that should be identical for all
// language specific help functions.
// DO NOT CHANGE THE NAME OF THE INCLUDED FILE BELOW
#include "help.icc"

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
