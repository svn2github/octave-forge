/*
 * Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the BSD License. For details see the COPYING
 * file included as part of this distribution.
 */

%module sqlite3;

%{
#include <sqlite3.h>
#include "generic_db.h"
%}

%typemap(in,numinputs=0,noblock=1) sqlite3 ** (sqlite3 *tmp=0) {
  $1=&tmp;
}
%typemap(argout,noblock=1) sqlite3 ** {
  %append_output(SWIG_NewPointerObj(%as_voidptr(result == SQLITE_OK ? *$1 : 0), SWIGTYPE_p_sqlite3, 1));
};

%typemap(in,numinputs=0,noblock=1) sqlite3_stmt ** (sqlite3_stmt *tmp=0) {
  $1=&tmp;
}
%typemap(argout,noblock=1) sqlite3_stmt ** {
  %append_output(SWIG_NewPointerObj(%as_voidptr(result == SQLITE_OK ? *$1 : 0), SWIGTYPE_p_sqlite3_stmt, 1));
};

%typemap(in,numinputs=0,noblock=1) const char **pzTail (char* tmp=0) {
  $1=&tmp;
}
%typemap(argout,noblock=1) const char **pzTail {
  %append_output(std::string(*$1?*$1:""));
};

%typemap(in,noblock=1) (const char *zSql,int nByte) (std::string tmp) {
  if (!$input.is_string()) {
    error("sql arg must be a string"); SWIG_fail;
  }
  tmp=$input.string_value();
  $1=(char*)tmp.c_str();
  $2=tmp.size();
}

%include "sqlite3_filtered.h"
%include "generic_db.h"

// *****************************************************************************
// * simplified api

%typemap(out,noblock=1) Cell {$result=$1;}

%inline {

  bool error_check(sqlite3* db,int r) {
    if (r!=SQLITE_OK) {
      error(sqlite3_errmsg(db));
      return false;
    }
    return true;
  }

  struct sqlite3_db : public generic_db {
    sqlite3* db;
    sqlite3_db(const char* name=":memory:") {
      error_check(db,sqlite3_open(name,&db));
    }
    ~sqlite3_db() {
      error_check(db,sqlite3_close(db));
    }

    Cell sql(const char* query) {
      sqlite3_stmt* stmt = 0;
      const char* tail = 0;
      if (!error_check(db,sqlite3_prepare
		       (db,query,strlen(query),&stmt,&tail)))
	return Cell();
      std::vector<octave_value> results;
      int n=-1;
      for (;;) {
	int r=sqlite3_step(stmt);
	if (r==SQLITE_DONE)
	  break;
	if (r!=SQLITE_ROW) {
	  error_check(db,r);
	  return Cell();
	}
	if (n<0)
	  n=sqlite3_column_count(stmt);
	for (int j=0;j<n;++j) {
	  switch (sqlite3_column_type(stmt,j)) {
	  case SQLITE_INTEGER:
	    results.push_back(sqlite3_column_int(stmt,j));
	    break;
	  case SQLITE_FLOAT:
	    results.push_back(sqlite3_column_double(stmt,j));
	    break;
	  case SQLITE_TEXT: {
	    const char* text=(const char*)sqlite3_column_text(stmt,j);
	    int text_len=sqlite3_column_bytes(stmt,j);
	    results.push_back(std::string(text,text_len));
	    break;
	  }
	  case SQLITE_NULL:
	    results.push_back(SWIG_NewPointerObj(0,SWIGTYPE_p_void,0));
	    break;
	  case SQLITE_BLOB: {
	    const char* data=(const char*)sqlite3_column_text(stmt,j);
	    int data_len=sqlite3_column_bytes(stmt,j);
	    results.push_back(charMatrix(std::string(data,data_len)));
	    break;
	  }
	  }
	}
      }
      error_check(db,sqlite3_finalize(stmt));
      assert(results.size()%n==0);
      int m=results.size()/n;
      Cell c(m,n);
      for (int j=0,l=0;j<m;++j)
	for (int k=0;k<n;++k)
	  c.elem(j,k)=results[l++];
      return c;
    }
  };
}
