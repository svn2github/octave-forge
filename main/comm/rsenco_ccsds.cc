#if !defined (__RSENCO_CCSDS_CC__)
#define __RSENCO__CCSDS_CC__

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <strstream>
#include <octave/oct.h>
#include "rsoct.h"

DEFUN_DLD (rsenco_ccsds, args, ,
           " Reed-Solomon encoder following the CCSDS\n"
           "\n"
	   " B = rsenco_ccsds(A) encodes a message A using the CCSDS\n"
	   "      standard. This uses a (255,223) code with 8-bit symbols\n"
           "      and a field generator of 1 + X + X^2 + X^7 + x^8 and a\n"
           "      code generator with first consecutive root of 112 and a\n"
           "      primitive element of 11. This function uses a dual basis\n"
           "      form\n" 
           "\n"
           " B = rsenco_ccsds(A, TYPE), as above but the type of the\n"
	   "      elements of A can be explicitly defined. Type can be\n"
           "      either\n"
           "        \"binary\"  - A is a column vector with elements of 1\n"
           "                      or 0\n"
           "        \"decimal\" - A is a column vector with elements between\n"
           "                      0 and 255\n"
           "        \"power\"   - A is a column vector with elements between\n"
           "                      -1 and 254\n"
           "      The form of the coded message B matches the form of the\n"
           "      input.\n"
           "\n"
           " [B ADDED] = rsenco_ccsds(...) since the Reed-Solomon code works\n"
           "      with blocks of 223 elements, zeros will need to be added\n"
           "      to A if it is not a multiple of 223 elements long (or\n"
           "      223*8 in the case of \"binary\" messages). So this form\n"
           "      returns how many zeros were added to A to meet this\n"
           "      criteria. ADDED is in terms of the same form as A.\n") {
  octave_value_list retval;

  RowVector msg;
  Matrix msg_matrix = args(0).matrix_value();
  MsgType msg_type = MSG_TYPE_BINARY;
  int i, j, l, added= 0, packets = 0, N = 255, M = 8, K = 223;
  unsigned char * code = NULL, * ptr;

  if ((msg_matrix.rows() > 1) && (msg_matrix.columns() > 1)) {
    cerr << "rsenco_ccsds: message must be a vector" << endl;
    return(retval);
  } else {
    if (msg_matrix.rows() > 1) 
      msg = msg_matrix.column(0);
    else
      msg = msg_matrix.row(0);
  }

  if (args.length() > 1) {
    if (args(1).is_string()) {
      string type = args(1).string_value();
      for (i=0;i<(int)type.length();i++)
	type[i] = toupper(type[i]);
      
      if (!type.compare("BINARY")) 
	msg_type = MSG_TYPE_BINARY;
      else if (!type.compare("POWER")) 
	msg_type = MSG_TYPE_POWER;
      else if (!type.compare("DECIMAL")) 
	msg_type = MSG_TYPE_DECIMAL;
      else {
	cerr << "rsenco_ccsds: Unknown message type" << endl;
	return(retval);
      }
    } else {
      cerr << "rsenco_ccsds: Type of message variable must be a string" 
	   << endl;
      return(retval);
    }
  }

  if (args.length() > 2) {
    cerr << "rsenco_ccsds: Too many arguments" << endl;
    return(retval);
  }

  switch (msg_type) {
  case MSG_TYPE_BINARY:
    packets = (msg.length() / M + K - 1) / K;
    code = (unsigned char *)calloc(N * packets, sizeof(unsigned char));
    if (code == NULL) {
      cerr << "rsenco_ccsds: Memory allocation error" << endl;
      return(retval);
    }
    added = packets*K*M - msg.length(); 
    for (j=0; j<packets; j++)
      for (i=0; i<K; i++) {
	code[j*N+i] = 0;
	for (l=0; l<M; l++)
	  if ((j*K+i)*M+l < msg.length())
	    if (msg((j*K+i)*M+l) != 0)
	      code[j*N+i] += (1 << l);
      }
    break;
  case MSG_TYPE_DECIMAL:
    packets = (msg.length() + K - 1) / K;
    code = (unsigned char *)calloc(N * packets, sizeof(unsigned char));
    if (code == NULL) {
      cerr << "rsenco_ccsds: Memory allocation error" << endl;
      return(retval);
    }
    added = packets*K - msg.length(); 
    for (j=0; j<packets; j++)
      for (i=0; i<K; i++) {
	if (j*K+i > msg.length()-1)
	  code[j*N+i] = 0;
	else {
	  if (msg(j*K+i) > N) {
	    cerr << "rsenco_ccsds: Illegal symbol " << endl;
	    free(code);
	    return(retval);
	  }
	  code[j*N+i] = (unsigned char)msg(j*K+i);
	}
      }
    break;
  case MSG_TYPE_POWER:
    packets = (msg.length() + K - 1) / K;
    code = (unsigned char *)calloc(N * packets, sizeof(unsigned char));
    if (code == NULL) {
      cerr << "rsenco_ccsds: Memory allocation error" << endl;
      return(retval);
    }
    added = packets*K - msg.length(); 
    for (j=0; j<packets; j++)
      for (i=0; i<K; i++) {
	if (j*K+i > msg.length()-1)
	  code[j*N+i] = 0;
	else {
	  if (msg(j*K+i) > N+1) {
	    cerr << "rsenco_ccsds: Illegal symbol" << endl;
	    free(code);
	    return(retval);
	  }
	  code[j*N+i] = (unsigned char)(msg(j*K+i) + 1);
	}
      }
    break;
  }

  ptr = code;
  for (l = 0; l < packets; l++) {
    encode_rs_ccsds(ptr, ptr+K);
    ptr += N;
  }

  if (msg_type == MSG_TYPE_BINARY) {
    ColumnVector code_ret(M*N*packets);
    ptr = code;
    for (j = 0; j < N*packets; j++) {
      for (i=0; i<M; i++) 
	code_ret(i + M*j) = (*ptr & (1<<i) ? 1 : 0);
      ptr++;
    }
    retval(0) = octave_value(code_ret);
  } else {
    ColumnVector code_ret(N*packets);
    ptr = code;
    for (j = 0; j < N*packets; j++) {
      code_ret(j) = *ptr++;
      if (msg_type == MSG_TYPE_POWER)
	code_ret(j) -= 1;
    }      
    retval(0) = octave_value(code_ret);
  }
  RowVector tmp(1,added);
  retval(1) = octave_value(tmp);
  free(code);
  return(retval);
}


#endif /* __RSENCO_CCSDS_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
