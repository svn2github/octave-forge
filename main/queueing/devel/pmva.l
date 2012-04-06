/****************************************************************************
 *
 * pmva.l
 *
 * Lexer for the PMVA notation.
 *
 * Copyright (C) 2011 Moreno Marzolla
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ****************************************************************************/

/*
 * See pmva.y for details
 */
%{
#include "stdio.h"
#include "pmva.h"
#include "y.tab.h"
int linenum=1;
%}

DIGITS [0-9]+
ID     [a-zA-Z][A-Za-z0-9_]*
WS     [ \t]+
LF     [\r\n]
FLOAT  {DIGITS}?\.{DIGITS}
INT    {DIGITS}

%%

{WS}     /* nothing to do */
{LF}     { linenum++; }
classes  { return TOK_CLASSES; }
servers  { return TOK_SERVERS; }
routing  { return TOK_ROUTING; }
network  { return TOK_NETWORK; }
end      { return TOK_END; }
FCFS     { return TOK_FCFS; }
PS       { return TOK_PS; }
IS       { return TOK_IS; }
LI       { return TOK_LI; }
MS       { return TOK_MS; }
LD       { return TOK_LD; }
POP      { return TOK_POP; }
MVA	 { return TOK_MVA; }
ASYMP    { return TOK_ASYMP; }
"=>"     { return TOK_ARROW; }
{FLOAT}  { return TOK_FLOAT; }
{INT}    { yylval.ival = atoi(yytext); return TOK_INT; }
{ID}     { 
		if ((yylval.id=malloc(yyleng+1)) == NULL) {
                     fprintf(stderr, "malloc() failed for id*\n");
                     exit(1);
                }
                strncpy(yylval.id, yytext, yyleng);
                yylval.id[yyleng] = '\0';
	        return TOK_ID; 
         }
.        { return yytext[0]; }

%%
int yywrap( void )
{
return 1;
}

