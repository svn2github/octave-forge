/*
 * Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the BSD License. For details see the COPYING
 * file included as part of this distribution.
 */

%module mysql

#pragma SWIG nowarn=451

%{
#include <mysql/mysql.h>
#include "generic_db.h"
#undef max_allowed_packet
#undef net_buffer_length
%}

struct MYSQL_ROW {};
%extend MYSQL_ROW {
  const char* __paren(int i) const {
    return (*$self)[i];
  }
}

// taken from mysql_com.h
enum enum_field_types { MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY,
			MYSQL_TYPE_SHORT,  MYSQL_TYPE_LONG,
			MYSQL_TYPE_FLOAT,  MYSQL_TYPE_DOUBLE,
			MYSQL_TYPE_NULL,   MYSQL_TYPE_TIMESTAMP,
			MYSQL_TYPE_LONGLONG,MYSQL_TYPE_INT24,
			MYSQL_TYPE_DATE,   MYSQL_TYPE_TIME,
			MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR,
			MYSQL_TYPE_NEWDATE, MYSQL_TYPE_VARCHAR,
			MYSQL_TYPE_BIT,
                        MYSQL_TYPE_NEWDECIMAL=246,
			MYSQL_TYPE_ENUM=247,
			MYSQL_TYPE_SET=248,
			MYSQL_TYPE_TINY_BLOB=249,
			MYSQL_TYPE_MEDIUM_BLOB=250,
			MYSQL_TYPE_LONG_BLOB=251,
			MYSQL_TYPE_BLOB=252,
			MYSQL_TYPE_VAR_STRING=253,
			MYSQL_TYPE_STRING=254,
			MYSQL_TYPE_GEOMETRY=255 };

%include "mysql_filtered.h"
%include "generic_db.h"

// *****************************************************************************
// * simplified api

%typemap(out,noblock=1) Cell {$result=$1;}

%inline {
  struct mysql_db : generic_db {
    MYSQL* db;
    mysql_db(const char* host,
	     const char* user,
	     const char* password,
	     const char* db_name) {
      db=mysql_init(0);
      if (!db) {
	error("failed to create MYSQL structure");
	return;
      }
      if (!mysql_real_connect(db,"localhost","root","secret","testdb",0,0,0)) {
	error("connect to database failed: error %i: %s",
	      mysql_errno(db),mysql_error(db));
	return;
      }
    }
    ~mysql_db() {
      if (db)
	mysql_close(db);
    }
    virtual Cell sql(const char* query) {
      if (!db) {
	error("invalid state");
	return Cell();
      }

      if (mysql_query(db,query)) {
	error("query failed: error %i: %s",
	      mysql_errno(db),mysql_error(db));
	return Cell();
      }

      MYSQL_RES* res=mysql_store_result(db);
      if (!res)
	return Cell();

      unsigned int nc=mysql_field_count(db);
      unsigned int nr=(unsigned int)(mysql_num_rows(res));

      std::vector<MYSQL_FIELD*> fields(nc);
      for (unsigned int j=0;j<nc;++j)
	fields[j]=mysql_fetch_field_direct(res,j);

      Cell c(nr,nc);
      octave_value ov;
      for (unsigned int j=0;j<nr;++j) {
	MYSQL_ROW row=mysql_fetch_row(res);
	for (unsigned int k=0;k<nc;++k) {
	  switch (fields[k]->type) {
	  case MYSQL_TYPE_DECIMAL:
	  case MYSQL_TYPE_SHORT:
	  case MYSQL_TYPE_TINY:
	  case MYSQL_TYPE_LONG:
	  case MYSQL_TYPE_INT24:
	    ov=octave_value(atol(row[k]));
	    break;
	  case MYSQL_TYPE_FLOAT:
	  case MYSQL_TYPE_DOUBLE:
	    ov=octave_value(atof(row[k]));
	    break;
	  case MYSQL_TYPE_LONGLONG:
	    ov=octave_value(octave_int64(atoll(row[k])));
	    break;
	  case MYSQL_TYPE_NULL:
	    ov=SWIG_NewPointerObj(0,SWIGTYPE_p_void,0);
	    break;
	  default:
	    ov=octave_value(std::string(row[k]));
	  }
	  c(j,k)=ov;
	}
      }

      mysql_free_result(res);
      return c;
    }
  };
}
