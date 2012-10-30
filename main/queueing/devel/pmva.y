/****************************************************************************
 *
 * pmva.y
 *
 * This grammar recognizes the PMVA notation for describing
 * queueing network models. This file is part of the queueing toolbox.
 *
 * Copyright (C) 2011, 2012 Moreno Marzolla
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
 * PMVA (Purdue Mean Value Analysis program) is described in
 * Jeff Brumfield, "PMVA - Purdue Mean Value Analysis Program User's Guide"
 * Technical Report CSD-TR-383, april 1981, Purdue University:
 *
 * http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1309&context=cstech
 *
 * This file contains a grammar for PMVA, according to the specification
 * above. At the moment, this grammar is only used to implement a parser
 * which does absolutely nothing (apart recognizing PMVA models). 
 * Eventually, this grammar will evolve in a suitable software tool
 * for generating an Octave model suitable for analysis with 
 * the queueing toolbox.
 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pmva.h"

extern int linenum;
extern FILE *yyin, *yyout;

#define YYERROR_VERBOSE 1
%}

%union{
  int ival;
  float fval;
  char* id;
};

%token <id> TOK_ID
%token <ival> TOK_INT
%token <fval> TOK_FLOAT
%token TOK_CLASSES
%token TOK_SERVERS
%token TOK_ROUTING
%token TOK_FCFS
%token TOK_PS
%token TOK_IS
%token TOK_LCFS
%token TOK_LI
%token TOK_MS
%token TOK_LD
%token TOK_ARROW
%token TOK_NETWORK
%token TOK_END
%token TOK_MVA
%token TOK_ASYMP
%token TOK_POP

%left ','
%left TOK_ARROW

%% /* The grammar follows */

input: /* empty */
| TOK_NETWORK ';' blocks TOK_END ';' solution_block
;

blocks: /* empty */
| blocks block
;

block: TOK_CLASSES class_list ';'
| TOK_SERVERS server_list ';'
| TOK_ROUTING routing_node_list ';'
;

class_list: /* empty */
| TOK_ID		{ push_class($1); }
| TOK_OD ',' class_list { push_class($1); }
;

server_list: /* empty */
| server
| server_list ',' server
;

server: TOK_ID { push_server($1); } queueing_discipline server_type service_times
;

queueing_discipline: /* empty (assume FCFS) */
| TOK_FCFS { server_list->queueing_discipline = FCFS; }
| TOK_PS   { server_list->queueing_discipline = PS; }
| TOK_IS   { server_list->queueing_discipline = IS; printf("m(%d) = -1;\n", n_servers); }
| TOK_LCFS { server_list->queueing_discipline = LCFS; }
;

server_type:  { printf("m(%d) = 1;\n", n_servers); } /* if not specified, assume LI */
| TOK_LI	{ server_list->server_type = LI; printf("m(%d) = 1;\n", n_servers); }
| TOK_MS TOK_INT { server_list->server_type = MS; server_list->num_servers = $2; printf("m(%d) = %d;\n", n_servers, $2); }
| TOK_LD	{ server_list->server_type = LD; printf("m(%d) = 1;\n", n_servers); }
;

service_times: service_time_spec
| service_times service_time_spec
;

service_time_spec: class_name visit_ratio service_time
;

class_name: /* empty */ { if (n_classes > 1) { printf("Class spwcified for server %s must be given for multiclass networks\n", server_list->name); exit(-1); } }
| TOK_ID '='
;

visit_ratio: /* empty */
| '[' TOK_FLOAT ']'
;

service_time: TOK_FLOAT
| '(' serv_time_list ')'
;

serv_time_list: TOK_FLOAT
| serv_time_list ',' TOK_FLOAT
;

routing_node_list: /* empty */
| nonempty_routing_spec
| routing_node_list ',' nonempty_routing_spec
;

nonempty_routing_spec: node_list
| nonempty_routing_spec TOK_ARROW node_list
;

node_list: TOK_ID opt_class_name opt_routing_prob
| node_list TOK_ID opt_class_name opt_routing_prob
;

opt_class_name: /* empty */
| '/' TOK_ID
;

opt_routing_prob: /* empty */
| '(' TOK_FLOAT ')'
;

solution_block: /* empty */
| TOK_ASYMP ';'
| TOK_MVA pop_description ';'
;

pop_description: TOK_POP '=' TOK_INT
| TOK_POP '=' '(' pop_list ')' 
;

pop_list: TOK_INT
| pop_list ',' TOK_INT
;

%%

server_node_t* server_list = 0;
class_node_t* class_list = 0;

int n_servers = 0;
int n_classes = 0;

/* 
 * Push a new server in front of the server list. Return the new head
 * of the list (the global variable server_list is also updated to
 * point to the newly created object). The caller transfers ownership
 * of the pointer name.
 */
server_node_t* push_server( const char* name )
{
  server_node_t* server = malloc( sizeof(server_node_t) );
  server->id = ++n_servers;
  server->name = name;
  server->queueing_discipline = FCFS;
  server->server_type = LI;
  server->num_servers = 1;
  server->next = server_list;
  server_list = server;
  printf("servers{%d} = \"%s\";\n", n_servers, name );
  return server;
}

class_node_t* push_class( const char* name )
{
  class_node_t* class = malloc( sizeof(class_node_t) );
  class->id = ++n_classes;
  class->name = name;
  class->next = class_list;
  class_list = class;
  printf("classes{%d}=\"%s\";\n", n_classes, name);
  return class;
}

void dump_server_list( void )
{
  server_node_t* server = server_list;
  while ( server ) {
    printf("[%d] %s ",server->id, server->name);

    switch ( server->server_type ) {
    case LI: printf("LI "); break;
    case LD: printf("LD "); break;
    case MS: printf("MS %d ", server->num_servers); break;
    default: printf("Unrecognized server type %d\n", server->server_type);
      exit(-1);
    }

    switch ( server->queueing_discipline ) {
    case FCFS: printf("FCFS "); break;
    case PS: printf("PS "); break;
    case LCFS: printf("LCFS "); break;
    case IS: printf("IS "); break;
    default: printf("Unrecognized queueing discipline %d\n", server->queueing_discipline );
      exit(-1);
    }      
    printf("\n");
    server = server->next;
  }
}

void dump_class_list( void )
{
  class_node_t* class = class_list;
  while( class ) {
    printf("[%d] %s\n", class->id, class->name );
    class = class->next;
  }
}

void yyerror(char const *s)
{
  fprintf(stderr, "line %d, %s\n", linenum, s);
  /*fprintf(stderr, "%s: (Error) line %d: %s\n", nomefile, linea, s); */
}

int main( int argc, char **argv )
{
  int res;
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;
  
  res = yyparse();
  /* dump_server_list();
     dump_class_list(); */
}
