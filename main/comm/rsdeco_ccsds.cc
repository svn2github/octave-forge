#if !defined (__RSDECO_CCSDS_CC__)
#define __RSDECO_CCSDS_CC__

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <strstream>
#include <octave/oct.h>
#include "rsoct.h"

DEFUN_DLD (rsdeco_ccsds, args, ,
           " Reed-Solomon decoder following the CCSDS standard\n"
	   "\n"
	   " B = rsdeco_ccsds(A) decodes a message A using the CCSDS\n"
	   "      standard. This uses a (255,223) code with 8-bit symbols\n"
           "      and a field generator of 1 + X + X^2 + X^7 + x^8 and a\n"
           "      code generator with first consecutive root of 112 and a\n"
           "      primitive element of 11. This function uses a dual basis\n"
           "      form\n" 
           "\n"
           " B = rsdeco_ccsds(A, TYPE), as above but the type of the\n"
	   "      elements of A can be explicitly defined. Type can be\n"
           "      either\n"
           "        \"binary\"  - A is a column vector with elements of 1\n"
           "                      or 0\n"
           "        \"decimal\" - A is a column vector with elements between\n"
           "                      0 and N\n"
           "        \"power\"   - A is a column vector with elements between\n"
           "                      -1 and N-1\n"
           "      The form of the decoded message B matches the form of the\n"
           "      input.\n"
	   "\n"
	   " B = rsdeco_ccsds(A, TYPE, Q) as above, but if Q is non-zero,\n"
	   "      inform about uncorrectable errors\n"
           "\n"
           " [B B_ERR] = rsdeco_ccsds(...) returns the number of burst\n"
           "      errors that occur within the blocks of the message B.\n"
           "\n"
           " [B B_ERR C] = rsdeco_ccsds(...) in addition returns the\n"
           "      corrected code\n"
           "\n"
           " [B B_ERR C C_ERR] = rsdeco_ccsds(...) in addition returns the\n"
           "      burst errors occuring in the corrected code\n"
           "\n"
           " [B B_ERR C C_ERR UNCORR] = rsdeco_ccsds(...) returns the number\n"
           "      of blocks that had uncorrectable errors\n") {
  octave_value_list retval;

  RowVector msg;
  Matrix msg_matrix = args(0).matrix_value();
  MsgType msg_type = MSG_TYPE_BINARY;
  int i, j, l, N = 255, M = 8, K = 223, count;
  int uncorr_err, packets = 0, quiet = 0;
  unsigned char * code = NULL, * ptr;
  
  if ((msg_matrix.rows() > 1) && (msg_matrix.columns() > 1)) {
    cerr << "rsdeco_ccsds: message must be a vector" << endl;
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
	cerr << "rsdeco_ccsds: Unknown message type" << endl;
	return(retval);
      }
    } else {
      cerr << "rsdeco_ccsds: Type of message variable must be a string" 
	   << endl;
      return(retval);
    }
  }

  if (args.length() > 2) 
    quiet = args(2).int_value();

  if (args.length() > 3) {
    cerr << "rsdeco_ccsds: Too many arguments" << endl;
    return(retval);
  }

  if ( (msg.length() % N) != 0) {
    cerr << "rsdeco_ccsds: The code vector has the incorrect length" << endl;
    return(retval);
  }

  switch (msg_type) {
  case MSG_TYPE_BINARY:
    packets = msg.length() / M / N;
    code = (unsigned char *)calloc(N * packets, sizeof(unsigned char));
    if (code == NULL) {
      cerr << "rsdeco_ccsds: Memory allocation error" << endl;
      return(retval);
    }
    for (j=0; j<packets; j++)
      for (i=0; i<N; i++) {
	code[j*N+i] = 0;
	for (l=0; l<M; l++)
	  if (msg((j*N+i)*M+l) != 0)
	       code[j*N+i] += (1 << l);
      }
    break;
  case MSG_TYPE_DECIMAL:
    packets = msg.length() / N;
    code = (unsigned char *)calloc(N * packets, sizeof(unsigned char));
    if (code == NULL) {
      cerr << "rsdeco_ccsds: Memory allocation error" << endl;
      return(retval);
    }
    for (j=0; j<packets; j++)
      for (i=0; i<N; i++) {
	if (j*N+i > msg.length()-1)
	  code[j*N+i] = 0;
	else {
	  if (msg(j*N+i) > N) {
	    cerr << "rsdeco_ccsds: Illegal symbol" << endl;
	    free(code);
	    return(retval);
	  }
	  code[j*N+i] = (unsigned char)msg(j*N+i);
	}
      }
    break;
  case MSG_TYPE_POWER:
    packets = msg.length() / N;
    code = (unsigned char *)calloc(N * packets, sizeof(unsigned char));
    if (code == NULL) {
      cerr << "rsdeco_ccsds: Memory allocation error" << endl;
      return(retval);
    }
    for (j=0; j<packets; j++)
      for (i=0; i<N; i++) {
	if (j*N+i > msg.length()-1)
	  code[j*N+i] = 0;
	else {
	  if (msg(j*N+i) > N-1) {
	    cerr << "rsdeco_ccsds: Illegal symbol" << endl;
	    free(code);
	    return(retval);
	  }
	  code[j*N+i] = (unsigned char)(msg(j*N+i) + 1);
	}
      }
    break;
  }

  ColumnVector err_blk(packets);
  ColumnVector bit_errors(packets);

  ptr = code;
  uncorr_err = 0;
  for (l = 0; l < packets; l++) {
    if ((count = decode_rs_ccsds(ptr, NULL, 0)) < 0) {
      uncorr_err++;
      if (quiet) {
	quiet = 0;
	cerr << "rsdeco_ccsds: warning uncorrected errors" << endl;
      }
      err_blk(l) = 0;
    } else
      err_blk(l) = count;
    ptr += N;
  }

  if (msg_type == MSG_TYPE_BINARY) {
    ColumnVector msg_ret(M*K*packets);
    ColumnVector msg_err_ret(M*K*packets);
    ColumnVector code_ret(M*N*packets);
    ColumnVector code_err_ret(M*N*packets);
    ptr = code;
    for (l = 0; l < packets; l++) {
      for (j = 0; j < K; j++) {
	for (i=0; i<M; i++) 
	  msg_ret((l*K+j)*M+i) = (*ptr & (1<<i) ? 1 : 0);
	ptr++;
      }
      ptr += N-K;
    }
    retval(0) = octave_value(msg_ret);
    for (l = 0; l < packets; l++)
      for (j = 0; j < K; j++)
	for (i=0; i<M; i++) 
	  msg_err_ret((l*K+j)*M+i) = err_blk(l);
    retval(1) = octave_value(msg_err_ret);
    ptr = code;
    for (j = 0; j < N*packets; j++) {
      for (i=0; i<M; i++) 
	code_ret(i + M*j) = (*ptr & (1<<i) ? 1 : 0);
      ptr++;
    }
    retval(2) = octave_value(code_ret);
    for (l = 0; l < packets; l++)
      for (j = 0; j < N; j++)
	for (i=0; i<M; i++) 
	  code_err_ret((l*N+j)*M+i) = err_blk(l);
    retval(3) = octave_value(code_err_ret);
    RowVector tmp(1,uncorr_err);
    retval(4) = octave_value(tmp);
    free(code);
    return(retval);
  } else {
    ColumnVector msg_ret(K*packets);
    ColumnVector msg_err_ret(K*packets);
    ColumnVector code_ret(N*packets);
    ColumnVector code_err_ret(N*packets);
    ptr = code;
    for (l = 0; l < packets; l++) {
      for (j = 0; j < K; j++) {
	msg_ret(l*K+j) = *ptr++;
	if (msg_type == MSG_TYPE_POWER)
	  code_ret(j) -= 1;
      }
      ptr += N-K;
    }
    retval(0) = octave_value(msg_ret);
    for (l = 0; l < packets; l++)
      for (j = 0; j < K; j++)
	  msg_err_ret(l*K+j) = err_blk(l);
    retval(1) = octave_value(msg_err_ret);
    ptr = code;
    for (l = 0; l < packets; l++) {
      for (j = 0; j < N; j++) {
	code_ret(l*N+j) = *ptr++;
	if (msg_type == MSG_TYPE_POWER)
	  code_ret(j) -= 1;
      }
    }
    retval(2) = octave_value(code_ret);
    for (l = 0; l < packets; l++)
      for (j = 0; j < N; j++)
	  code_err_ret(l*N+j) = err_blk(l);
    retval(3) = octave_value(code_err_ret);
    RowVector tmp(1,uncorr_err);
    retval(4) = octave_value(tmp);
    free(code);
    return(retval);
  }
}


#endif /* __RSDECO_CCSDS_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
