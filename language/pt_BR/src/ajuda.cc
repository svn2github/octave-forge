/*

Copyright (C) 2007 Jorge Barros de Abreu

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
// or .pt_BR for brazilian portuguese
#define LANG_EXT ".pt_BR"

// Function name, both with and without the quotes. This should match the
// file name that is chosen for the help function.
#define HELP_NAME ajuda
#define HELP_STRING "ajuda"

// The final word in the following PKG_ADD command should match the above
// PKG_ADD: mark_as_command ajuda

// The texinfo formatted help message for the function. Please be careful
// that accented characters respect texinfo formatting
#define HELP_TEXT  \
 "@deftypefn {Comando} {} ajuda @var{nomearqivo}\n\
  @deftypefnx {Fun@,{c}@~ao Carreg@'avel} {} ajuda (@var{nomearqivo})\n\
  Fun@,{c}@~ao de ajuda em Portugu@^es do Brasil.\n"

// Some additional non texinfo formatted message 
#define NOT_FOUND "não encontrado" 
#define NOT_DOCUMENTED "não está documentado"
#define MD5_MISMATCH \
  "MD5 não coincide na seqüência de caracteres traduzida.\nUse `help' para obter a seqüência de caracteres original"
#define TEXINFO_ERROR_1 "A formatação do filtro terminou de forma inesperada"
#define TEXINFO_ERROR_2 "O código fonte Texinfo do texto de ajuda encontra-se adiante..."

// Additional help message.
#define ADDITIONAL_HELP \
"Ajuda adicional para funções internas e operadores está\n\
disponível na versão on-line do manual.  Use o comando\n\
`doc <tópico>' para procurar o índice do manual.\n\
\n\
Ajuda e informação sobre o Octave está também disponível na WWW\n\
em http://www.octave.org e através do e-mail help@octave.org\n\
que é uma lista de discurssão.\n"

// Language specific macros and seealso macro
#define MAKEINFO_MACROS \
"@documentencoding ISO-8859-1\n\
@set cedilha @,{c}\n\
@set o_til @~o\n\
@macro seealso {args}\n\
@sp 1\n\
@noindent\n\
Veja tamb@'em: \\args\\.\n\
@end macro\n"

// Below is a bit of magic that allows the indexing script to correctly
// find the function and the help text. Yes it is supposed to be commented,
// and whether the indexing script finds the macros correctly is very sensitive
// to the formatting (leave the dummy comment). Please note that DEFUN_DLD 
// must appear on a newline. The first argument name needs to be the same 
// as HELP_NAME
/*
DEFUN_DLD_DUMMY (ajuda, 
"-*- texinfo -*-\n" 
MAKEINFO_MACROS
"@c dummy comment\n"
HELP_TEXT
"@seealso{help, doc}\n\
@end deftypefn")
*/

// This includes the part of the function that should be identical for all
// language specific help functions
// DO NOT CHANGE THE NAME OF THE INCLUDED FILE BELOW
#include "help.icc"

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
