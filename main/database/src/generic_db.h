/*
 * Copyright (c) 2008, Xavier Delacour <xavier.delacour@gmail.com>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the BSD License. For details see the COPYING
 * file included as part of this distribution.
 */

#include <octave/oct.h>
#include <octave/Cell.h>

struct generic_db {
  virtual ~generic_db() {}
  virtual Cell sql(const char* query)=0;
};
