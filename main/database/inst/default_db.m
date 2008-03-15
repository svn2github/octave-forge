# Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
#
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the BSD License. For details see the COPYING
# file included as part of this distribution.

# usage: db = default_db()
#        db = default_db(db)
# This function is used to store a database object instance for later
# use by sql() calls that don't specify a db. The first form returns the
# current default database, and the second form changes it and returns
# the new value.

function db=default_db(db)
  global __octave_db_default;
  if (nargin==1)
    __octave_db_default=db;
  endif
  db=__octave_db_default;
end
