/*
 * Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the BSD License. For details see the LICENSE
 * file included as part of this distribution.
 */

%module postgres

%{
#include <postgresql/libpq-fe.h>
#include "generic_db.h"
%}

typedef unsigned int Oid;

%include "libpq-fe_filtered.h"
%include "pg_type_filtered.h"
%include "generic_db.h"

// *****************************************************************************
// * simplified api

%typemap(out,noblock=1) Cell {$result=$1;}

%inline {

  struct postgres_db : public generic_db {
    PGconn *conn;
    postgres_db(const char* conninfo) {
      conn=PQconnectdb(conninfo);
      if (PQstatus(conn)!=CONNECTION_OK)
	error("failed connecting to database: %s",PQerrorMessage(conn));
    }
    ~postgres_db() {
      PQfinish(conn);
    }
    virtual Cell sql(const char* query) {
      if (!conn) {
	error("database not in valid state");
	return Cell();
      }
      PGresult *res=PQexec(conn,query);
      ExecStatusType rst=PQresultStatus(res);
      if (rst!=PGRES_COMMAND_OK&&rst!=PGRES_TUPLES_OK) {
	error("postgres error: %s, %s",PQresStatus(rst),PQresultErrorMessage(res));
	return Cell();
      }

      int n=PQntuples(res);
      int m=PQnfields(res);
      Cell c(n,m);
      octave_value ov;
      for (int i=0;i<n;++i)
	for (int j=0;j<m;++j) {
	  if (PQgetisnull(res,i,j)) {
	    ov=SWIG_NewPointerObj(0,SWIGTYPE_p_void,0);
	  } else {
	    const char* v=PQgetvalue(res,i,j);
	    switch (PQftype(res,j)) {
	    case BOOLOID:
	      ov=octave_value(v[0]=='t');
	      break;
	    case INT8OID:
	      ov=octave_int64(atoll(v));
	      break;
	    case INT2OID:
	    case INT4OID:
	      ov=octave_value(atoi(v));
	      break;
	    case FLOAT4OID:
	    case FLOAT8OID:
	      ov=octave_value(atof(v));
	      break;
	    default:
	      ov=octave_value(std::string(v));
	    }
	  }
	  c.elem(i,j)=ov;
	}
      PQclear(res);
      return c;
    }
  };
}

