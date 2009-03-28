/*

Copyright (C) 2009 Javier Enciso

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this software; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/


// These are the language specific parts of this file that need changing

// Language file extension. For example .fr for french, .pt or portuguese
// or .pt_BR for Brazilian
#define LANG_EXT ".es_CO"

// Function name, both with and without the quotes. This should match the
// file name that is chosen for the help function.
#define HELP_NAME ayuda
#define HELP_STRING "ayuda"

// The final word in the following PKG_ADD command should match the above
// PKG_ADD: mark_as_command ayuda

// The texinfo formatted help message for the function. Please be careful
// that accented characters respect texinfo formatting
#define HELP_TEXT  \
 "@deftypefn {Comando} {} ayuda @var{tema}\n\
  @deftypefnx {Funci@'on cargable} {} ayuda (@var{tema})\n\
  Funci@'on de ayuda en Espa@~nol.\n"

// Some additional non texinfo formatted message 
#define NOT_FOUND "no encontrado" 
#define NOT_DOCUMENTED "no está documentado"
#define MD5_MISMATCH "MD5 no coincide con el texto traducido.\nUse `ayuda' para ver el texto de ayuda original"
#define TEXINFO_ERROR_1 "El filtro de formato de Texinfo ha terminado en forma inesperada"
#define TEXINFO_ERROR_2 "Fuente de Texinfo sin formato del texto de ayuda a continuación..."

// Additional help message.
#define ADDITIONAL_HELP \
"Información adicional acerca de las funciones incorporadas y\n\
operadores se encuentra disponible en la versión en línea del manual.\n\
Use el comando `doc <tema>' para buscar en el índice del manual.\n\
\n\
Para ayuda e información adicional acerca de Octave visite\n\
el sitio http://www.octave.org o a través de la lista de correos\n\
help@octave.org.\n"

// Language specific macros and seealso macro
#define MAKEINFO_MACROS \
"@documentencoding ISO-8859-1\n\
@set cedilha @,{c}\n\
@set o_til @~o\n\
@macro seealso {args}\n\
@sp 1\n\
@noindent\n\
Ve@'ase tambi@'en: \\args\\.\n\
@end macro\n"

// Below is a bit of magic that allows the indexing script to correctly
// find the function and the help text. Yes it is supposed to be commented,
// and whether the indexing script finds the macros correctly is very sensitive
// to the formatting (leave the dummy comment). Please note that DEFUN_DLD 
// must appear on a newline. The first argument name needs to be the same 
// as HELP_NAME
/*
DEFUN_DLD_DUMMY (ayuda, 
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
