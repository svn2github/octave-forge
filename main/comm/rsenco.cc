#if !defined (__RSENCO_CC__)
#define __RSENCO_CC__

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <strstream>
#include <octave/oct.h>
#include "rsoct.h"

DEFUN_DLD (rsenco, args, ,
           " Reed-Solomon encoder\n"
           "\n"
           " B = rsenco(A, N, K) encodes the message A with a word length\n"
           "      of N and a message length of K. The value of N must be of\n"
           "      the form 2^M - 1 and K < N. To speed the calculation N can\n"
           "      be the elements of the Galois field GF(2^M) where N is\n"
           "      is 2^M-by-M matrix. A must be a column vector and its\n"
	   "      elements are assumed to be either 1 or 0.\n"
           "\n"
           " B = rsenco(A, N, K, TYPE), as above but the type of the elements\n"
	   "      of A can be explicitly defined. Type can be either\n"
           "        \"binary\"  - A is a column vector with elements of 1\n"
           "                      or 0\n"
           "        \"decimal\" - A is a column vector with elements between\n"
           "                      0 and N\n"
           "        \"power\"   - A is a column vector with elements between\n"
           "                      -1 and N-1\n"
           "      The form of the coded message B matches the form of the\n"
           "      input.\n"
           "\n"
           " B = rsenco(A, N, K, TYPE, Gg) explicitly supply the generator\n"
           "      polynomial of the Reed-Solomon code (see rspoly). Gg must\n"
	   "      be an output of rspoly since there is no checking of Gg.\n"
	   "\n"
	   " B = rsenco(A, N, K, TYPE, Gg, Fcr) if Gg was created with a\n"
           "      root that was not 1, then the first root must be\n"
	   "      explicitly defined with this argument\n"
	   "\n"
	   " B = rsenco(A, N, K, TYPE, Gg, Fcr, Prim) if Gg was created with\n"
	   "      a primitive element that was not 1, then it must be\n"
           "      explicitly defined with this argument\n"
           "\n"
           " [B ADDED] = rsenco(...) since the Reed-Solomon code works with\n"
           "      blocks of K elements, zeros will need to be added to A if\n"
           "      it is not a multiple of K elements long (or K*M in the\n" 
           "      case of \"binary\" messages). So this form of rsenco\n"
           "      returns how many zeros were added to A to meet this\n"
           "      criteria. ADDED is in terms of the same form as A.\n"
           "\n"
           " Note that one difference between this code at that of Matlab\n"
	   " is that the parity symbols are stored at the end of the data\n"
           " block and not the beginning. This should not be important if\n"
           " the only code supplied here is used to manipulate the data\n") {
  octave_value_list retval;

  RowVector msg;
  Matrix msg_matrix = args(0).matrix_value();
  MsgType msg_type = MSG_TYPE_BINARY;
  int i, j, l, N, M, K, added= 0, packets = 0;
  int * code = NULL, * ptr;
  struct rs *rshandle;

  if ((msg_matrix.rows() > 1) && (msg_matrix.columns() > 1)) {
    cerr << "rsenco: message must be a vector" << endl;
    return(retval);
  } else {
    if (msg_matrix.rows() > 1) 
      msg = msg_matrix.column(0);
    else
      msg = msg_matrix.row(0);
  }

  if (args.length() < 3) {
    cerr << "rsenco: too few arguments" << endl;
    return(retval);
  }

  if (args(1).is_real_scalar()) {
    N = args(1).int_value();
    M = 0;
    for (i=0; i<32; i++) {
      if ( (N+1) & (1<<i)) {
	if (M != 0) {
	  cerr << "rsenco: N must be of the form 2^M -1" << endl;
	  return(retval);
	} else
	  M = i;
      }
    }
    K = args(2).int_value();
    if (K >= N) {
      cerr << "rsenco: K must be less than N" << endl;
      return(retval);
    }

    int indx = find_table_index(M);
    if (indx < 0) {
      cerr << "rsenco: No default primitive polynominal for" <<
	" desired symbol length" << endl;
      return(retval);
    }
    rshandle = (rs *)init_rs_int(M, _RS_Tab[indx].genpoly, 1, 1, N-K);
  } else {
    Matrix tuple = args(1).matrix_value();
    N = tuple.rows() - 1;
    M = tuple.columns();
    if (N != ((1<<M)-1)) {
      cerr << "rsenco: Galois field matrix of incorrect form" << endl;
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
      cerr << "rsenco: K must be less than N" << endl;
      return(retval);
    }

    rshandle = (rs *)init_rs_int(M, gfpoly, 1, 1, N-K);
  }

  if (args.length() > 3) {
    if (args(3).is_string()) {
      string type = args(3).string_value();
      for (i=0;i<(int)type.length();i++)
	type[i] = toupper(type[i]);
      
      if (!type.compare("BINARY")) 
	msg_type = MSG_TYPE_BINARY;
      else if (!type.compare("POWER")) 
	msg_type = MSG_TYPE_POWER;
      else if (!type.compare("DECIMAL")) 
	msg_type = MSG_TYPE_DECIMAL;
      else {
	cerr << "rsenco: Unknown message type" << endl;
	free_rs_int(rshandle);
	return(retval);
      }
    } else {
      cerr << "rsenco: Type of message variable must be a string" << endl;
      free_rs_int(rshandle);
      return(retval);
    }
  }
    
  if (!rshandle) {
    /* Above use default polynomials that are primitive. Thus allocation err */
    cerr << "rsenco: Memory allocation error" << endl;
    return(retval);
  }

  if (args.length() > 4) {
    Matrix VecGg = args(4).matrix_value();
    if ((VecGg.rows() > 1) && (VecGg.columns() > 1)) {
      cerr << "rsenco: Generator polynomial must be a vector" << endl;
      free_rs_int(rshandle);
      return(retval);
    }

    if ((VecGg.rows() > VecGg.columns() ? VecGg.rows() : VecGg.columns()) 
	< N - K + 1) {
      cerr << "rsenco: Generator polynomial of incorrect length" << endl;
      free_rs_int(rshandle);
      return(retval);
    }
    
    if (VecGg.rows() > 1) {
      // Paranoia that we just might have to put this back into place
      int *tmpptr = rshandle->genpoly;
      rshandle->nroots = VecGg.rows()-1;
      rshandle->genpoly = (int *)malloc(sizeof(int)*VecGg.rows());
      if (rshandle->genpoly == NULL) {
	cerr << "rsenco: Memory allocation error" << endl;
	// Ok we have to be careful here freeing the rs struct, since
	// we have part of it that is now NULL. Put old ptr ack in place
	rshandle->genpoly = tmpptr;
	free_rs_int(rshandle);
	return(retval);
      }
      free(tmpptr);
      for (i=0; i<VecGg.rows(); i++)
	rshandle->genpoly[i] = (int)VecGg.elem(i,0);
    } else {
      // Paranoia that we just might have to put this back into place
      int *tmpptr = rshandle->genpoly;
      rshandle->nroots = VecGg.columns()-1;
      rshandle->genpoly = (int *)malloc(sizeof(int)*VecGg.columns());
      if (rshandle->genpoly == NULL) {
	cerr << "rsenco: Memory allocation error" << endl;
	// Ok we have to be careful here freeing the rs struct, since
	// we have part of it that is now NULL. Put old ptr ack in place
	rshandle->genpoly = tmpptr;
	free_rs_int(rshandle);
	return(retval);
      }
      free(tmpptr);
      for (i=0; i<VecGg.columns(); i++)
	rshandle->genpoly[i] = (int)VecGg.elem(0,i);
    }

    if (args.length() > 5)
      rshandle->fcr = args(5).int_value();
    if (args.length() > 6) {
      rshandle->prim = args(6).int_value();

      /* Find prim-th root of 1, used in decoding */
      int iprim;
      for(iprim=1;(iprim % rshandle->prim) != 0;iprim += N)
	;
      rshandle->iprim = iprim / rshandle->prim;
    }
  }

  if (args.length() > 7) {
    cerr << "rsenco: Too many arguments" << endl;
    free_rs_int(rshandle);
    return(retval);
  }

  switch (msg_type) {
  case MSG_TYPE_BINARY:
    packets = (msg.length() / M + K - 1) / K;
    code = (int *)calloc(N * packets, sizeof(int));
    if (code == NULL) {
      cerr << "rsdeco: Memory allocation error" << endl;
      free_rs_int(rshandle);
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
    code = (int *)calloc(N * packets, sizeof(int));
    if (code == NULL) {
      cerr << "rsdeco: Memory allocation error" << endl;
      free_rs_int(rshandle);
      return(retval);
    }
    added = packets*K - msg.length(); 
    for (j=0; j<packets; j++)
      for (i=0; i<K; i++) {
	if (j*K+i > msg.length()-1)
	  code[j*N+i] = 0;
	else
	  code[j*N+i] = (int)msg(j*K+i);
      }
    break;
  case MSG_TYPE_POWER:
    packets = (msg.length() + K - 1) / K;
    code = (int *)calloc(N * packets, sizeof(int));
    if (code == NULL) {
      cerr << "rsdeco: Memory allocation error" << endl;
      free_rs_int(rshandle);
      return(retval);
    }
    added = packets*K - msg.length(); 
    for (j=0; j<packets; j++)
      for (i=0; i<K; i++) {
	if (j*K+i > msg.length()-1)
	  code[j*N+i] = 0;
	else  {
	  code[j*N+i] = (int)(msg(j*K+i) + 1);
	  if (code[j*N+i] < 0) code[j*N+i] = 0;
	}
      }
    break;
  }

  ptr = code;
  for (j=0; j<N*packets; j++)
    if (*ptr++ > N) {
      cerr << "rsenco: Illegal symbol" << endl;
      free_rs_int(rshandle);
      free(code);
      return(retval);
    }
  
  ptr = code;
  for (l = 0; l < packets; l++) {
    encode_rs_int(rshandle, ptr, ptr+K);
    ptr += N;
  }
    
  free_rs_int(rshandle);

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


#endif /* __RSENCO_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
