#if !defined (__RSDECO_CC__)
#define __RSDECO_CC__

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <octave/oct.h>
#include "rsoct.h"

DEFUN_DLD (rsdeco, args, ,
           " Reed-Solomon decoder\n"
	   "\n"
           " B = rsdeco(A, N, K) decodes the code A with a word length\n"
           "      of N and a message length of K. The value of N must be of\n"
           "      the form 2^M - 1 and K < N. To speed the calculation N can\n"
           "      be the elements of the Galois field GF(2^M) where N is\n"
           "      is 2^M-by-M matrix. A must be a column vector and its\n"
	   "      elements are assumed to be either 1 or 0.\n"
           "\n"
           " B = rsdeco(A, N, K, TYPE), as above but the type of the elements\n"
	   "      of A can be explicitly defined. Type can be either\n"
           "        \"binary\"  - A is a column vector with elements of 1\n"
           "                      or 0\n"
           "        \"decimal\" - A is a column vector with elements between\n"
           "                      0 and N\n"
           "        \"power\"   - A is a column vector with elements between\n"
           "                      -1 and N-1\n"
           "      The form of the decoded message B matches the form of the\n"
           "      input.\n"
           "\n"
	   " B = rsdeco(A, N, K, TYPE, Fcr) If you have explicitly coded\n"
	   "      with a generator polynomial whose first root is not 1\n"
	   "      define the first root\n"
	   "\n"
	   " B = rsdeco(A, N, K, TYPE, Fcr, Prim) If you have explicitly\n"
	   "      coded witha generator polynomial whose primitive element\n"
	   "      is not 1, it must be explicitly defined with this variable\n"
	   "\n"
           " [B B_ERR] = rsdeco(...) returns the number of burst errors that\n"
           "      occur within the blocks of the message B.\n"
           "\n"
           " [B B_ERR C] = rsdeco(...) in addition returns the corrected\n"
           "      code\n"
           "\n"
           " [B B_ERR C C_ERR] = rsdeco(...) in addition returns the burst\n"
           "      errors occuring in the corrected code\n"
           "\n"
           " [B B_ERR C C_ERR UNCORR] = rsdeco(...) returns the number of\n"
           "      blocks that had uncorrectable errors\n"
           "\n"
           " Note that one difference between this code at that of Matlab\n"
	   " is that the parity symbols are stored at the end of the data\n"
           " block and not the beginning. This should not be important if\n"
           " the only code supllied here is used to manipulate the data\n") {
  octave_value_list retval;

  RowVector msg;
  Matrix msg_matrix = args(0).matrix_value();
  MsgType msg_type = MSG_TYPE_BINARY;
  int i, j, l, N, M, K, count;
  int uncorr_err, packets = 0;
  int * code = NULL, * ptr;
  struct rs *rshandle;

  if ((msg_matrix.rows() > 1) && (msg_matrix.columns() > 1)) {
    error("rsdeco: message must be a vector");
    return(retval);
  } else {
    if (msg_matrix.rows() > 1)
      msg = msg_matrix.column(0);
    else
      msg = msg_matrix.row(0);
  }

  if (args.length() < 3) {
    error("rsdeco: too few arguments");
    return(retval);
  }

  if (args(1).is_real_scalar()) {
    N = args(1).int_value();
    M = 0;
    for (i=0; i<32; i++) {
      if ( (N+1) & (1<<i)) {
	if (M != 0) {
	  error("rsdeco: N must be of the form 2^M -1");
	  return(retval);
	} else
	  M = i;
      }
    }
    K = args(2).int_value();
    if (K >= N) {
      error("rsdeco: K must be less than N");
      return(retval);
    }

    int indx = find_table_index(M);
    if (indx < 0) {
      error("rsenco: No default primitive polynominal for desired symbol length");
      return(retval);
    }
    rshandle = (rs *)init_rs_int(M, _RS_Tab[indx].genpoly, 1, 1, N-K);
  } else {
    Matrix tuple = args(1).matrix_value();
    N = tuple.rows() - 1;
    M = tuple.columns();
    if (N != ((1<<M)-1)) {
      error("rsdeco: Galois field matrix of incorrect form");
      return(retval);
    }

    /* This case is a pain as the gftuple basically gives me
     * alpha_to[] from the rshandle struct. Basically what I
     * have to do, is find the primitive polynominal given
     * in alpha_to[] and then use it with init_rs. Luckily
     * alpha_to[M] always contains the primitive polynomial!!
     */
    unsigned int gfpoly = 0;
    for (int j=0; j<M; j++)
      gfpoly += ((int)tuple.elem(M+1,j)) << j;
    gfpoly += (1<<M);

    K = args(2).int_value();
    if (K >= N) {
      error("rsenco: K must be less than N");
      return(retval);
    }

    rshandle = (rs *)init_rs_int(M, gfpoly, 1, 1, N-K);
  }

  if (args.length() > 3) {
    if (args(3).is_string()) {
      std::string type = args(3).string_value();
      for (i=0;i<(int)type.length();i++)
	type[i] = toupper(type[i]);

      if (!type.compare("BINARY"))
	msg_type = MSG_TYPE_BINARY;
      else if (!type.compare("POWER"))
	msg_type = MSG_TYPE_POWER;
      else if (!type.compare("DECIMAL"))
	msg_type = MSG_TYPE_DECIMAL;
      else {
	error("rdeco: Unknown message type");
	free_rs_int(rshandle);
	return(retval);
      }
    } else {
      error("rsdeco: Type of message variable must be a string");
      free_rs_int(rshandle);
      return(retval);
    }
  }

  if ( (msg.length() % N) != 0) {
    error("rsdeco: The code vector has the incorrect length");
    free_rs_int(rshandle);
    return(retval);
  }

  if (args.length() > 4)
    rshandle->fcr = args(4).int_value();
  if (args.length() > 5) {
    rshandle->prim = args(5).int_value();

    /* Find prim-th root of 1, used in decoding */
    int iprim;
    for(iprim=1;(iprim % rshandle->prim) != 0;iprim += N)
      ;
    rshandle->iprim = iprim / rshandle->prim;
  }

  if (args.length() > 6) {
    error("rsdeco: Too many arguments");
    free_rs_int(rshandle);
    return(retval);
  }

  if (!rshandle) {
    /* Above use default polynomials that are primitive. Thus allocation err */
    error("rsenco: Memory allocation error");
    return(retval);
  }

  switch (msg_type) {
  case MSG_TYPE_BINARY:
    packets = msg.length() / M / N;
    code = (int *)calloc(N * packets, sizeof(int));
    if (code == NULL) {
      error("rsdeco: Memory allocation error");
      free_rs_int(rshandle);
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
    code = (int *)calloc(N * packets, sizeof(int));
    if (code == NULL) {
      error("rsdeco: Memory allocation error");
      free_rs_int(rshandle);
      return(retval);
    }
    for (j=0; j<packets; j++)
      for (i=0; i<N; i++) {
	if (j*N+i > msg.length()-1)
	  code[j*N+i] = 0;
	else
	  code[j*N+i] = (int)msg(j*N+i);
      }
    break;
  case MSG_TYPE_POWER:
    packets = msg.length() / N;
    code = (int *)calloc(N * packets, sizeof(int));
    if (code == NULL) {
      error("rsdeco: Memory allocation error");
      free_rs_int(rshandle);
      return(retval);
    }
    for (j=0; j<packets; j++)
      for (i=0; i<N; i++) {
	if (j*N+i > msg.length()-1)
	  code[j*N+i] = 0;
	else {
	  code[j*N+i] = (int)msg(j*N+i) + 1;
	  if (code[j*N+i] < 0) code[j*N+i] = 0;
	}
      }
    break;
  }

  ColumnVector err_blk(packets);
  ColumnVector bit_errors(packets);

  ptr = code;
  for (l = 0; l < N*packets; l++) {
    if (*ptr++ > N) {
      error("rsdeco: Illegal symbol");
      free_rs_int(rshandle);
      free(code);
      return(retval);
    }
  }

  ptr = code;
  uncorr_err = 0;
  for (l = 0; l < packets; l++) {
    if ((count = decode_rs_int(rshandle, ptr, NULL, 0)) < 0) {
      uncorr_err++;
      err_blk(l) = 0;
    } else
      err_blk(l) = count;
    ptr += N;
  }

  free_rs_int(rshandle);

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


#endif /* __RSDECO_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
