/*
 * Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the BSD License. For details see the LICENSE
 * file included as part of this distribution.
 */


// documentation for this API is available here:
// http://msdn2.microsoft.com/en-us/library/ms714562(VS.85).aspx
// http://www.easysoft.com/developer/interfaces/odbc/linux.html

%module odbc

%{
#include <sql.h>
#include <sqlext.h>
#include "generic_db.h"
%}

%define %typemap_handle_return(Type,Name)
%typemap(in,numinputs=0,noblock=1) Type *Name (Type tmp=0) {
  $1=&tmp;
}
%typemap(argout,noblock=1) Type *Name {
  %append_output(SWIG_NewPointerObj(%as_voidptr(*$1), SWIGTYPE_p_void, 1));
}
%enddef
%typemap_handle_return(SQLHDBC,ConnectionHandle);
%typemap_handle_return(SQLHENV,EnvironmentHandle);
%typemap_handle_return(SQLHANDLE,OutputHandle);
%typemap_handle_return(SQLHSTMT,StatementHandle);
%typemap_handle_return(SQLPOINTER,Value);

%typemap(in,numinputs=0,noblock=1) SQLINTEGER* OUTPUT (SQLINTEGER tmp=0) {
  $1=&tmp;
}
%typemap(argout,noblock=1) SQLINTEGER* OUTPUT {
  %append_output(octave_value(*$1));
}
%apply SQLINTEGER* OUTPUT { SQLINTEGER *RowCount };

%typemap(in,numinputs=0,noblock=1) SQLSMALLINT* OUTPUT (SQLSMALLINT tmp=0) {
  $1=&tmp;
}
%typemap(argout,noblock=1) SQLSMALLINT* OUTPUT {
  %append_output(octave_value(*$1));
}
%apply SQLSMALLINT* OUTPUT { SQLSMALLINT *ColumnCount };

// SQLConnect
%typemap(in,noblock=1) (SQLCHAR *TEXT, SQLINTEGER LENGTH) (std::string tmp) {
  if (!$input.is_string()) {
    error("arg must be a string"); SWIG_fail;
  }
  tmp=$input.string_value();
  $1=(unsigned char*)tmp.c_str();
  $2=tmp.size();
}
%apply (SQLCHAR *TEXT, SQLINTEGER LENGTH) { (SQLCHAR *StatementText, SQLINTEGER TextLength) };
%apply (SQLCHAR *TEXT, SQLINTEGER LENGTH) { (SQLCHAR *ServerName, SQLSMALLINT NameLength1) };
%apply (SQLCHAR *TEXT, SQLINTEGER LENGTH) { (SQLCHAR *UserName, SQLSMALLINT NameLength2) };
%apply (SQLCHAR *TEXT, SQLINTEGER LENGTH) { (SQLCHAR *Authentication, SQLSMALLINT NameLength3) };

// SQLDescribeCol
%typemap(in,numinputs=0,noblock=1) (SQLCHAR *ColumnName, SQLSMALLINT BufferLength, SQLSMALLINT *NameLength) (SQLCHAR tmp[512], SQLSMALLINT tmp2=0) {
  $1=tmp;
  $2=sizeof(tmp);
  $3=&tmp2;
}
%typemap(argout,noblock=1) (SQLCHAR *ColumnName, SQLSMALLINT BufferLength, SQLSMALLINT *NameLength) {
  %append_output(std::string((const char*)$1));
}
%apply SQLSMALLINT* OUTPUT { SQLSMALLINT *DataType };
%typemap(in,numinputs=0,noblock=1) SQLUINTEGER *ColumnSize (SQLUINTEGER tmp=0) { $1=&tmp; };
%typemap(argout,noblock=1) SQLUINTEGER *ColumnSize { %append_output($1); };
%typemap(in,numinputs=0,noblock=1) SQLSMALLINT *DecimalDigits (SQLSMALLINT tmp=0) { $1=&tmp; };
%typemap(in,numinputs=0,noblock=1) SQLSMALLINT *Nullable (SQLSMALLINT tmp=0) { $1=&tmp; };

// SQLGetDiagRec
%typemap(in,numinputs=0,noblock=1) SQLCHAR *Sqlstate (SQLCHAR tmp[32]) {
  tmp[0]=0; $1=tmp;
}
%typemap(argout,noblock=1) SQLCHAR *Sqlstate {
  %append_output(octave_value(std::string((const char*)$1)));
}
%apply SQLINTEGER* OUTPUT { SQLINTEGER *NativeError };
%typemap(in,numinputs=0,noblock=1) (SQLCHAR *MessageText,
				    SQLSMALLINT BufferLength, 
				    SQLSMALLINT *TextLength) (SQLCHAR tmp[256]) {
  tmp[0]=0; $1=tmp;
}
%typemap(argout,noblock=1) (SQLCHAR *MessageText,
				    SQLSMALLINT BufferLength, 
				    SQLSMALLINT *TextLength) {
  %append_output(octave_value(std::string((const char*)$1)));
}

%include "sqltypes_filtered.h"
%include "sqlext_filtered.h"
%include "sql_filtered.h"
%include "generic_db.h"

// SQLGetData
%typemap(in,numinputs=0,noblock=1) std::string* value (std::string tmp) {
  $1=&tmp;
}
%typemap(argout,noblock=1) std::string* value {
  %append_output(octave_value(*$1));
}
%apply SQLINTEGER* OUTPUT { SQLINTEGER *ind };
%inline {
  SQLRETURN  SQL_API SQLGetData(SQLHSTMT StatementHandle,
				SQLUSMALLINT ColumnNumber, 
				std::string* value,
				SQLLEN* ind) {
    SQLRETURN res;
    char buf[128];
    *ind=0;
    value->resize(0);
    for (;;) {
      res=SQLGetData(StatementHandle,ColumnNumber,SQL_C_CHAR,
			       buf,sizeof(buf),ind);
      if (*ind==SQL_NO_TOTAL||*ind==SQL_NULL_DATA)
	return res;
      int rdlen=*ind>sizeof(buf)?sizeof(buf)-1:*ind;
      value->insert(value->end(),buf,buf+rdlen);
      if (*ind<sizeof(buf))
	break;
    }
    *ind=value->size();
    return res;
  }
}

// *****************************************************************************
// * simplified api

%typemap(out,noblock=1) Cell {$result=$1;}

%inline {

  class odbc_db : public generic_db {
    bool check_error(SQLRETURN r,SQLSMALLINT htype,SQLHANDLE h) {
      if (r!=SQL_STILL_EXECUTING&&r!=SQL_ERROR&&r!=SQL_INVALID_HANDLE)
	return true;

      char state[32]={0};
      SQLINTEGER __errno=0;
      char errmsg[256]={0};
      SQLSMALLINT tmp=0;
      SQLGetDiagRec(htype,h,1,(SQLCHAR*)&state,&__errno,(SQLCHAR*)errmsg,
		    sizeof(errmsg),&tmp);
      error("odbc error %i: %s",__errno,errmsg);
      return false;
    }
  public:
    SQLHENV env;
    SQLHDBC conn;

    odbc_db(const char* dsn,const char* user,const char* password) 
      : env(0),conn(0) {
      SQLRETURN r;
      r=SQLAllocEnv(&env);
      if (!check_error(r,SQL_HANDLE_ENV,env))
	return;
      r=SQLAllocConnect(env,&conn);
      if (!check_error(r,SQL_HANDLE_DBC,conn))
	return;
      r=SQLConnect(conn,(SQLCHAR*)dsn,strlen(dsn),(SQLCHAR*)user,strlen(user),
		   (SQLCHAR*)password,strlen(password));
      if (!check_error(r,SQL_HANDLE_DBC,conn))
	return;
    }
    ~odbc_db() {
      if (conn) {
	SQLDisconnect(conn);
	SQLFreeConnect(conn);
      }
      if (env)
	SQLFreeEnv(env);
    }
    virtual Cell sql(const char* query) {
      SQLRETURN r;
      SQLHSTMT stmt;

      r=SQLAllocStmt(conn,&stmt);
      if (!check_error(r,SQL_HANDLE_STMT,stmt))
	return Cell();
      r=SQLExecDirect(stmt,(SQLCHAR*)query,strlen(query));
      if (!check_error(r,SQL_HANDLE_STMT,stmt))
	return Cell();

      SQLLEN nr=0;
      SQLSMALLINT nc=0;
      r=SQLRowCount(stmt,&nr);
      if (!check_error(r,SQL_HANDLE_STMT,stmt))
	return Cell();
      r=SQLNumResultCols(stmt,&nc);
      if (!check_error(r,SQL_HANDLE_STMT,stmt))
	return Cell();

      if (nr<=0||nc<=0)
	return Cell();

      std::vector<SQLSMALLINT> ctypes(nc);
      SQLCHAR tmp[128];
      SQLSMALLINT tmplen=0;
      SQLULEN tmp2=0;
      SQLSMALLINT tmp3=0;
      SQLSMALLINT tmp4=0;
      for (int j=0;j<nc;++j) {
	r=SQLDescribeCol(stmt,j+1,tmp,sizeof(tmp),&tmplen,&ctypes[j],
			 &tmp2,&tmp3,&tmp4);
	if (!check_error(r,SQL_HANDLE_STMT,stmt))
	  return Cell();
      }

      Cell c(nr,nc);
      octave_value ov;
      std::string v;
      for (int j=0;;++j) {
	r=SQLFetch(stmt);
	if (!check_error(r,SQL_HANDLE_STMT,stmt))
	  return Cell();
	if (r==SQL_NO_DATA)
	  break;
	assert(j<nr);
	for (int k=0;k<nc;++k) {
	  SQLLEN ind=0;
	  r=SQLGetData(stmt,k+1,&v,&ind);
	  if (!check_error(r,SQL_HANDLE_STMT,stmt))
	    return Cell();
	  if (ind==SQL_NULL_DATA)
	    ov=SWIG_NewPointerObj(0,SWIGTYPE_p_void,0);
	  else {
	    switch (ctypes[k]) {
	    case SQL_DECIMAL:
	    case SQL_INTEGER:
	    case SQL_SMALLINT:
	      ov=octave_value(atol(v.c_str()));
	      break;
	    case SQL_NUMERIC:
	    case SQL_FLOAT:
	    case SQL_REAL:
	    case SQL_DOUBLE:
	      ov=octave_value(atof(v.c_str()));
	      break;
	    case SQL_CHAR:
	    case SQL_VARCHAR:
	    default:
	      ov=octave_value(v);
	    }
	  }
	  c.elem(j,k)=ov;
	}
      }

      r=SQLFreeStmt(stmt,0);
      if (!check_error(r,SQL_HANDLE_STMT,stmt))
	return Cell();
      return c;
    }
  };

}
