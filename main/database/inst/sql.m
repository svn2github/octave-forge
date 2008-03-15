# Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
#
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the BSD License. For details see the COPYING
# file included as part of this distribution.

# usage: results = sql(db, query);
#        results = sql(query);
# where query is a string giving SQL query, and db is a database object
# instance (constructed with postgres_db(), mysql_db(), sqlite3_db(),
# and odbc_db()). Omitting the db argument is possible if one has called
# default_db() previously.
# For examples, see http://octave-swig.sourceforge.net/octave-db.html.


function res=sql(varargin)
  global __octave_db_default;
  if (length(varargin)==1)
    if (!strcmp(typeinfo(__octave_db_default),"swig_ref"))
      error("you must call default_db first, or supply db argument");
    endif
    res=__octave_db_default.sql(varargin{1});
  elseif (length(varargin)==2)
    res=varargin{1}.sql(varargin{2});
  else
    error("usage: sql([db,]query)");
  endif
end
