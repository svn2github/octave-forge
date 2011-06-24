// Copyright (C) 2010, 2011 Olaf Till

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#if !defined (sock_stream_h)
#define sock_stream_h

// (this comment and the definition have been taken from pserver.cc
// and were probably from Hayato Fujiwara)
//
// SSIZE_MAX might be for 64-bit. Limit to 2^31-1
#define BUFF_SIZE 2147483647

int socket_to_oct_iostream (int sd);

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
