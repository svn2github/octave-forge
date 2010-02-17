// Copyright (C) 2009 Riccardo Corradini <riccardocorradini@yahoo.it>
// under the terms of the GNU General Public License.
// Copyright (C) 2009 VZLU Prague
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; If not, see <http://www.gnu.org/licenses/>.
/*
 * Receives most Octave datatypes into contiguous memory
 * using derived datatypes
 * info = MPI_Send(var,rank,comunicator)
 */
#include "simple.h"
#include <ov-cell.h>    // avoid errmsg "cell -- incomplete datatype"
#include <oct-map.h>    // avoid errmsg "Oct.map -- invalid use undef type"


// tested on Octave 3.2.4
#define HAVE_OCTAVE_324 =1
#ifndef HAVE_OCTAVE_324
enum ov_t_id
{

ov_unknown=0,                // t_id=0
ov_cell,                // t_id=1
ov_scalar,                // t_id=2
ov_complex_scalar,            // t_id=3
ov_matrix,                // t_id=4
ov_diagonal_matrix,            // t_id=5
ov_complex_matrix,            // t_id=6
ov_complex_diagonal_matrix,        // t_id=7
ov_range,                // t_id=8
ov_bool,                // t_id=9
ov_bool_matrix,                // t_id=10
ov_string,                // t_id=11
ov_sq_string,                // t_id=12
ov_int8_scalar,                // t_id=13
ov_int16_scalar,            // t_id=14
ov_int32_scalar,            // t_id=15
ov_int64_scalar,            // t_id=16
ov_uint8_scalar,            // t_id=17
ov_uint16_scalar,            // t_id=18
ov_uint32_scalar,            // t_id=19
ov_uint64_scalar,            // t_id=20
ov_int8_matrix,            // t_id=21
ov_int16_matrix,            // t_id=22
ov_int32_matrix,                    // t_id=23
ov_int64_matrix,                    // t_id=24
ov_uint8_matrix,            // t_id=25
ov_uint16_matrix,            // t_id=26
ov_uint32_matrix,            // t_id=27
ov_uint64_matrix,            // t_id=28
ov_sparse_bool_matrix,            // t_id=29

ov_sparse_matrix,                        // t_id=30
ov_sparse_complex_matrix,
ov_struct,
ov_class,
ov_list,
ov_cs_list,
ov_magic_colon,
ov_built_in_function,
ov_user_defined_function,
ov_dynamically_linked_function,
ov_function_handle,
ov_inline_function,
ov_float_scalar,
ov_float_complex_scalar,
ov_float_matrix,
ov_float_diagonal_matrix,
ov_float_complex_matrix,
ov_float_complex_diagonal_matrix,
ov_permutation_matrix,
ov_null_matrix,
ov_null_string,
ov_null_sq_string,
};





#else
enum ov_t_id
{

ov_unknown=0,                // t_id=0
ov_cell,                // t_id=1
ov_scalar,                // t_id=2
ov_complex_scalar,            // t_id=3
ov_matrix,                // t_id=4
ov_diagonal_matrix,            // t_id=5
ov_complex_matrix,            // t_id=6
ov_complex_diagonal_matrix,        // t_id=7
ov_range,                // t_id=8
ov_bool,                // t_id=9
ov_bool_matrix,                // t_id=10
ov_char_matrix,                // t_id=11
ov_string,                // t_id=12
ov_sq_string,                // t_id=13
ov_int8_scalar,                // t_id=14
ov_int16_scalar,            // t_id=15
ov_int32_scalar,            // t_id=16
ov_int64_scalar,            // t_id=17
ov_uint8_scalar,            // t_id=18
ov_uint16_scalar,            // t_id=19
ov_uint32_scalar,            // t_id=20
ov_uint64_scalar,            // t_id=21
ov_int8_matrix,            // t_id=22
ov_int16_matrix,            // t_id=23
ov_int32_matrix,                    // t_id=24
ov_int64_matrix,                    // t_id=25
ov_uint8_matrix,            // t_id=26
ov_uint16_matrix,            // t_id=27
ov_uint32_matrix,            // t_id=28
ov_uint64_matrix,            // t_id=29
ov_sparse_bool_matrix,            // t_id=30

ov_sparse_matrix,                        // t_id=31
ov_sparse_complex_matrix,
ov_struct,
ov_class,
ov_list,
ov_cs_list,
ov_magic_colon,
ov_built_in_function,
ov_user_defined_function,
ov_dynamically_linked_function,
ov_function_handle,
ov_inline_function,
ov_float_scalar,
ov_float_complex_scalar,
ov_float_matrix,
ov_float_diagonal_matrix,
ov_float_complex_matrix,
ov_float_complex_diagonal_matrix,
ov_permutation_matrix,
ov_null_matrix,
ov_null_string,
ov_null_sq_string,
};

#endif // HAVE_OCTAVE_324

/*----------------------------------*/        /* forward declaration */



int recv_class( MPI_Comm comm, octave_value &ov,  int source, int mytag);        /* along the datatype */
/*----------------------------------*/    /* to receive any octave_value */
 
int recv_cell(MPI_Comm comm,octave_value &ov, int source, int mytag);
int recv_struct( MPI_Comm comm, octave_value &ov, int source, int mytag);
int recv_string( MPI_Comm comm, octave_value &ov,int source, int mytag);
int recv_range(MPI_Comm comm, Range &range,int source, int mytag);

template<class AnyElem>
int recv_vec(MPI_Comm comm, AnyElem &LBNDA, int nitem, MPI_Datatype TRCV ,int source, int mytag);

int recv_matrix(int t_id, MPI_Comm comm, octave_value &ov,int source, int mytag);
int recv_sp_mat(int t_id, MPI_Comm comm, octave_value &ov,int source, int mytag);

template <class Any>
int recv_scalar(int t_id, MPI_Comm comm, Any *d, int source, int mytag);
template <class Any>
int recv_scalar(int t_id, MPI_Comm comm, std::complex<Any> *d, int source, int mytag);


int recv_range(MPI_Comm comm, Range &range,int source, int mytag){        /* put base,limit,incr,nelem */
/*-------------------------------*/        /* just 3 doubles + 1 int */
// octave_range (double base, double limit, double inc)
  MPI_Status stat;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(double,d,3);
  d[0]= range.base();
  d[1]= range.limit();
  d[2]= range.inc();

  int info = MPI_Recv(d, 3, MPI_INT,  source, tanktag[1] , comm,&stat);
   
return(info);
}

// This will get the fortran_vec vector for Any type Octave can handle
template<class AnyElem>
int recv_vec(MPI_Comm comm, AnyElem &LBNDA, int nitem  ,MPI_Datatype TRCV ,int source, int mytag)
{
		      MPI_Datatype fortvec;
		      MPI_Type_contiguous(nitem,TRCV, &fortvec);
		      MPI_Type_commit(&fortvec);
		      MPI_Status stat;
		      int info = MPI_Recv((LBNDA), 1,fortvec, source, mytag , comm,&stat);
  return(info);
}



// template specialization for complex case
template <class Any>
int recv_scalar(int t_id, MPI_Comm comm, std::complex<Any> &d, int source, int mytag){        
  int info;
  MPI_Status stat;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(std::complex<Any>,Deco,2);
  Deco[0] = real(d);
  Deco[1] = imag(d);
  // Most of scalars are real not complex
  MPI_Datatype TRcv;
  switch (t_id) {
		  TRcv = MPI_DOUBLE;
		  TRcv = MPI_FLOAT;
		}
		
  info = MPI_Recv((&Deco), 2,TRcv, source, tanktag[1] , comm,&stat);
  if (info !=MPI_SUCCESS) return info;

  return(info);
}

template <class Any>
int recv_scalar(int t_id, MPI_Comm comm, Any &d, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  MPI_Datatype TRcv;
    switch (t_id) {
		case ov_scalar:  		TRcv = MPI_DOUBLE;
		case ov_bool: 			TRcv = MPI_INT;
		case ov_float_scalar:   	TRcv = MPI_FLOAT;
		case ov_int8_scalar:   		TRcv = MPI_BYTE;
		case ov_int16_scalar:   	TRcv = MPI_SHORT;
		case ov_int32_scalar:   	TRcv = MPI_INT;
		case ov_int64_scalar:   	TRcv = MPI_LONG_LONG;
		case ov_uint8_scalar:  		TRcv = MPI_UNSIGNED_CHAR;
		case ov_uint16_scalar:  	TRcv = MPI_UNSIGNED_SHORT;
		case ov_uint32_scalar:  	TRcv = MPI_UNSIGNED;
		case ov_uint64_scalar:  	TRcv = MPI_UNSIGNED_LONG_LONG;
                }
  info = MPI_Recv((&d), 1,TRcv, source, tanktag[1] , comm,&stat);
  if (info !=MPI_SUCCESS) return info;
   return(info);
}
int recv_string( MPI_Comm comm, octave_value &ov,int source, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a  string value */
std::string cpp_string;
OCTAVE_LOCAL_BUFFER(int, tanktag, 2);
tanktag[0]=mytag;
tanktag[1]=mytag+1;
tanktag[2]=mytag+2;

  int info,nitem;
  MPI_Status stat;
  info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//   printf("I have received number of elements  %i \n",nitem);
  OCTAVE_LOCAL_BUFFER(char,mess,nitem+1);
  if (info !=MPI_SUCCESS) return info;
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem+1,MPI_CHAR, &fortvec);
  MPI_Type_commit(&fortvec);


   info = MPI_Recv(mess, 1,fortvec, source, tanktag[2] , comm,&stat);
//    printf("Flag for string received  %i \n",info);
   
   cpp_string = mess;
   ov = cpp_string;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}


int recv_matrix( int t_id,const MPI_Comm comm, octave_value &ov,  int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 6);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
tanktag[5] = mytag+5;
  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//  	  printf("info for nitem=%i\n",info);
//  	  printf("nitem=%i\n",nitem);
      if (info !=MPI_SUCCESS) return info;
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//  	  printf("info for nd=%i\n",info);
//  	  printf("nd=%i\n",nd);
      if (info !=MPI_SUCCESS) return info;

//  Now create contiguous datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
//  	  printf("info for dim vector=%i\n",info);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
   dv(i) = dimV[i] ;
 }
   
  MPI_Datatype TRCV;
		if (t_id == ov_matrix)
		      {
			NDArray myNDA(dv);
		      OCTAVE_LOCAL_BUFFER(double, LBNDA,nitem);
		      TRCV = MPI_DOUBLE;
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			ov=myNDA;  
		      } 
		      
		else if (t_id==ov_complex_matrix)
		      {
		      OCTAVE_LOCAL_BUFFER(double,LBNDA1,nitem);
		      TRCV = MPI_DOUBLE;
		      info = recv_vec(comm, LBNDA1,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      ComplexNDArray myNDA(dv);  
		      OCTAVE_LOCAL_BUFFER(double,LBNDA2,nitem);
		      info = recv_vec(comm, LBNDA2,nitem ,TRCV ,source, tanktag[5]);
		      if (info !=MPI_SUCCESS) return info;
			for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=real(LBNDA1[i])+imag(LBNDA2[i]);
			  }
			  ov=myNDA;
		      }  
		else if (t_id ==ov_bool_matrix)
		      {
		      OCTAVE_LOCAL_BUFFER(bool,LBNDA,nitem);
		      TRCV = MPI_INT;
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      boolNDArray   myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      }	  
		else if (t_id==ov_float_matrix)
		      {
		      TRCV = MPI_FLOAT;
		      OCTAVE_LOCAL_BUFFER(float,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      FloatNDArray   myNDA(dv);   
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      } 	  
		else if (t_id==ov_float_complex_matrix)
		     {
		      TRCV = MPI_FLOAT;
		      OCTAVE_LOCAL_BUFFER(float,LBNDA1,nitem);
		      info = recv_vec(comm, LBNDA1,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;		  
		      OCTAVE_LOCAL_BUFFER(float,LBNDA2,nitem);
		      info = recv_vec(comm, LBNDA2,nitem ,TRCV ,source, tanktag[5]);
		      if (info !=MPI_SUCCESS) return info;
		      FloatComplexNDArray myNDA(dv); 
			for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=real(LBNDA1[i])+imag(LBNDA2[i]);
			  }
			  ov=myNDA;
		      }
		else if  (t_id==ov_int8_matrix)   
		      {  	
			TRCV = MPI_BYTE;
			OCTAVE_LOCAL_BUFFER(octave_int8,LBNDA1,nitem);
			info = recv_vec(comm, LBNDA1,nitem ,TRCV ,source, tanktag[4]);
			if (info !=MPI_SUCCESS) return info;
			int8NDArray myNDA(dv);
			for (octave_idx_type i=0; i<nitem; i++)
			    {
				myNDA(i)=LBNDA1[i];
			    }
			    ov=myNDA;
		      }
		else if (t_id==ov_int16_matrix)  
		{  	
		      TRCV = MPI_SHORT;
		      OCTAVE_LOCAL_BUFFER(octave_int16,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      int16NDArray myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		} 		
		else if (ov_int32_matrix)  {  	TRCV = MPI_INT;
		      OCTAVE_LOCAL_BUFFER(octave_int32,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      int32NDArray myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      } 		
		else if (ov_int64_matrix)  {  	TRCV = MPI_LONG_LONG;
		      OCTAVE_LOCAL_BUFFER(octave_int64,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      int64NDArray myNDA(dv);
		      if (info !=MPI_SUCCESS) return info;
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      } 		
		else if (ov_uint8_matrix)  { 		TRCV = MPI_UNSIGNED_CHAR;
		      OCTAVE_LOCAL_BUFFER(octave_uint8,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      uint8NDArray myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      } 		
		else if (ov_uint16_matrix) {  	TRCV = MPI_UNSIGNED_SHORT;
		      OCTAVE_LOCAL_BUFFER(octave_uint16,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      uint16NDArray myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      } 		
		else if (ov_uint32_matrix) { 	TRCV = MPI_UNSIGNED;
		      OCTAVE_LOCAL_BUFFER(octave_uint32,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      uint32NDArray myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			ov = myNDA;  
		      } 		
		else if (ov_uint64_matrix) 
		      { 	
		      TRCV = MPI_UNSIGNED_LONG_LONG;
		      OCTAVE_LOCAL_BUFFER(octave_uint64,LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      uint64NDArray myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  } 
		      ov=myNDA;
		      }
return(info);

}


int recv_sp_mat(int t_id, MPI_Comm comm, octave_value &ov,int source, int mytag){   
int info;   
MPI_Datatype TRcv;
                
OCTAVE_LOCAL_BUFFER(int, tanktag,6);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
tanktag[5] = mytag+5;

MPI_Status stat;

OCTAVE_LOCAL_BUFFER(int,s,3);  

// Create a contiguous derived datatype
MPI_Datatype sintsparse;
MPI_Type_contiguous(3,MPI_INT, &sintsparse);
MPI_Type_commit(&sintsparse);




// receive the sintsparse vector named s
info = MPI_Recv(s, 1, sintsparse, source, tanktag[1], comm, &stat);
// printf("This is info for sintsparse %i\n",info);
if (info !=MPI_SUCCESS) return info;
// MPI_Datatype datavect1;
// MPI_Type_contiguous(s[2],TRcv, &datavect1);
// MPI_Type_commit(&datavect1);
// printf("This is info for sintsparse %i\n");
// Create a contiguous derived datatype for row and column index
 
OCTAVE_LOCAL_BUFFER(int,sridx,s[2]); 
MPI_Datatype rowindex;
MPI_Type_contiguous(s[2],MPI_INT, &rowindex);
MPI_Type_commit(&rowindex);

OCTAVE_LOCAL_BUFFER(int,scidx,s[1]+1); 
MPI_Datatype columnindex;
MPI_Type_contiguous(s[1]+1,MPI_INT, &columnindex);
MPI_Type_commit(&columnindex);


      info =  MPI_Recv(sridx,1,rowindex,source,tanktag[2],comm,&stat);
//        printf("Hope everything is fine here with ridx %i =\n",info);
      if (info !=MPI_SUCCESS) return info;

// receive the vector with column indexes
      info =  MPI_Recv(scidx,1,columnindex,source,tanktag[3],comm, &stat);
//      printf("Hope everything is fine here with scidx %i =\n",info);
      if (info !=MPI_SUCCESS) return info;

// Now we have a different vector of non zero elements according to datatype

	      if (t_id == ov_sparse_bool_matrix)
		{  
		  TRcv = MPI_INT;
		  SparseBoolMatrix m(s[0],s[1],s[2]);
		  OCTAVE_LOCAL_BUFFER(bool,LBNDA,s[2]);
		  //Now receive the vector of non zero elements
		  info = recv_vec(comm, LBNDA,s[2] ,TRcv ,source, tanktag[4]);
//  		  printf("This is info for vector of non zero elements %i\n",info);
		  if (info !=MPI_SUCCESS) return info;
		  for (octave_idx_type i = 0; i < s[1]+1; i++)
		  {
		    m.cidx(i) = scidx[i];
		  }
		  for (octave_idx_type i = 0; i < s[2]; i++)
		  {
		  m.ridx(i) = sridx[i];
// 		  printf("LBNDA[i]= %f\n",LBNDA[i]);
		  m.data(i) = LBNDA[i];
		  }
		  ov = m;
		}
		if (t_id == ov_sparse_matrix)
		{  
		  TRcv = MPI_DOUBLE;
		  SparseMatrix m(s[0],s[1],s[2]);
		  OCTAVE_LOCAL_BUFFER(double,LBNDA,s[2]);
		  //Now receive the vector of non zero elements
		  info = recv_vec(comm, LBNDA,s[2] ,TRcv ,source, tanktag[4]);
//  		  printf("This is info for receiving vector of non zero elements %i\n",info);
		  if (info !=MPI_SUCCESS) return info;
		  for (octave_idx_type i = 0; i < s[1]+1; i++)
		  {
		    m.cidx(i) = scidx[i];
		  }
		  for (octave_idx_type i = 0; i < s[2]; i++)
		  {
		  m.ridx(i) = sridx[i];
// 		  printf("LBNDA[i]= %f\n",LBNDA[i]);
		  m.data(i) = LBNDA[i];
		  }
		  ov = m;
		}
		if (t_id == ov_sparse_complex_matrix)
		{  
		  TRcv = MPI_DOUBLE;
		  SparseComplexMatrix m(s[0],s[1],s[2]);
		  OCTAVE_LOCAL_BUFFER(double,LBNDA1,s[2]);
		  OCTAVE_LOCAL_BUFFER(double,LBNDA2,s[2]);
		  info = recv_vec(comm, LBNDA1,s[2] ,TRcv ,source, tanktag[4]);
		  if (info !=MPI_SUCCESS) return info;
		  info = recv_vec(comm, LBNDA2,s[2] ,TRcv ,source, tanktag[5]);
		  if (info !=MPI_SUCCESS) return info;		  
		  for (octave_idx_type i = 0; i < s[1]+1; i++)
		  {
		    m.cidx(i) = scidx[i];
		  }
		  for (octave_idx_type i = 0; i < s[2]; i++)
		  {
		  m.ridx(i) = sridx[i];
		  m.data(i) = real(LBNDA1[i])+imag(LBNDA2[i]);
		  }
		  ov = m;

		}
return(info);


}
int recv_cell(MPI_Comm comm,octave_value &ov, int source, int mytag){
// Not tested yet
OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
      info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//          printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//            printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguous datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
//        printf("I have received number dimension vector and this is the flag .. %i \n",info);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
   
   dv(i) = dimV[i] ;
//      printf("I am printing dimvector  %i \n",dimV[i]);
 }

Cell	    oc (dv);
// Now focus on every single octave_value
int newtag = tanktag[4];
int ocap;
         for (octave_idx_type i=0; i<nitem; i++)
	    {
	      octave_value celem;				
	      info = MPI_Recv((&ocap), 1,MPI_INT, source, newtag , comm,&stat);
//                printf("I have received the identifier's TAG  of the specific  octave_value %i \n",ocap);
	      if (info !=MPI_SUCCESS) return info;
	      newtag = newtag+ocap;
	      
// 	       printf("I have received NEWTAG+1  = %i\n",newtag+1);
	      info=recv_class(comm,celem,source,newtag);
//                printf("This is info for the specific  octave_value %i \n",info);
	      if (info !=MPI_SUCCESS) return info;
	      oc.Array<octave_value>::elem(i)=celem;        
	    }

ov = oc;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);

}

int recv_struct( MPI_Comm comm, octave_value &ov, int source, int mytag){      
Octave_map om;
int n; // map.fields();

OCTAVE_LOCAL_BUFFER(int, tanktag, 2);
tanktag[0]=mytag; //t_id
tanktag[1]=mytag+1; // n
int tagcap = mytag+2;
int   ntagkey = mytag+3; // string
int   ctag = mytag + 4; // cell
  int info;
  MPI_Status stat;
  info = MPI_Recv((&n), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//   printf("I have received n with info = % i \n",info);
  int scap;  
  for (int i=0; i<n; i++){			/* nkeys: foreach, get key */
    octave_value ov_string;
    ntagkey = ntagkey + 3;
    info = recv_class(comm, ov_string,source,ntagkey);
//     printf("I have received the string with info = % i \n",info);
    std::string key = ov_string.string_value();
    if( (info!=MPI_SUCCESS) )	return(info);
    octave_value conts;				/* all elements on this fname */
//     Receives capacity
    info = MPI_Recv(&scap, 1,MPI_INT,source,tagcap, comm, &stat);
//     printf("I have received capacity with info = % i \n",info);
    tagcap = tagcap+1;
    ctag = ctag + scap;
    info = recv_class(comm, conts,source,ctag);
//      printf("I have received cell with info = % i \n",info);
    if (! conts.is_cell())			return(MPI_ERR_UNKNOWN);
    om.assign (key, conts.cell_value());
  }
  if (n != om.nfields()){
// 	  printf("MPI_Recv: inconsistent map length\n");return(MPI_ERR_UNKNOWN);
  }

  ov=om;
  
  return(MPI_SUCCESS);
}


int recv_class(MPI_Comm comm, octave_value &ov, int source, int mytag ){    /* varname-strlength 1st, dims[ndim] */
/*----------------------------------*/    /* and then appropriate specific info */
  int t_id,n;
  MPI_Status status;
//      printf("1-> source =%i\n",source);
//      printf("2-> tag for id =%i\n",mytag);
     
  int info = MPI_Recv(&t_id,1, MPI_INT, source,mytag,comm,&status);

//         printf(" I have received t_id =%i\n",t_id);

  switch (t_id) {
    case ov_cell		: return(recv_cell ( comm,  ov,source,mytag));
    case ov_struct		: return(recv_struct(comm,  ov,source,mytag)); 
    case ov_scalar		: {double 	 d=0;  info =(recv_scalar (t_id,comm, d,source,mytag));ov=d;return(info);};
    case ov_bool		: {bool 	 b;    info = (recv_scalar (t_id,comm, b,source,mytag));   ov=b ;return(info);};
    case ov_int8_scalar         : {octave_int8   d;    info = (recv_scalar (t_id,comm, d,source,mytag)); ov=d ;return(info);};
    case ov_int16_scalar        : {octave_int16  d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);};
    case ov_int32_scalar        : {octave_int32  d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);};
    case ov_int64_scalar        : {octave_int64  d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);};
    case ov_uint8_scalar        : {octave_uint8  d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);}; 
    case ov_uint16_scalar       : {octave_uint16 d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);};
    case ov_uint32_scalar       : {octave_uint32 d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);};
    case ov_uint64_scalar       : {octave_uint64 d;    info = (recv_scalar (t_id,comm, d,source,mytag));   ov=d ;return(info);};
    case ov_float_scalar        : {float 	       d;    info =(recv_scalar (t_id,comm, d,source,mytag)) ;  ov=d;return(info);};
    case ov_complex_scalar      : {std::complex<double>   d;    info =(recv_scalar (t_id,comm, d,source,mytag)) ;  ov=d;return(info);};
    case ov_float_complex_scalar: {std::complex<float> d;    info =(recv_scalar (t_id,comm, d,source,mytag)) ;  ov=d;return(info);};
    case ov_string		: return(recv_string (comm, ov,source,mytag));
    case ov_sq_string		: return(recv_string (comm, ov,source,mytag));
    case ov_range		: {Range 	       d;    info =(recv_range (comm, d,source,mytag));	ov=d;return(info);};
    case ov_matrix    		: return(recv_matrix (t_id,comm,ov,source,mytag));	
    case ov_complex_matrix    	: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_bool_matrix		: return(recv_matrix (t_id,comm,ov,source,mytag));  
    case ov_int8_matrix		: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_int16_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_int32_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_int64_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));

    case ov_uint8_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_uint16_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_uint32_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));
    case ov_uint64_matrix	: return(recv_matrix (t_id,comm,ov,source,mytag));

    case ov_float_matrix:            	return(recv_matrix (t_id,comm, ov,source,mytag));
    case ov_float_complex_matrix:    	return(recv_matrix (t_id,comm, ov,source,mytag));
    case ov_sparse_matrix:		return(recv_sp_mat(t_id,comm, ov,source,mytag));
    case ov_sparse_complex_matrix:   	return(recv_sp_mat(t_id,comm, ov,source,mytag));			
    case ov_unknown:    printf("MPI_Recv: unknown class\n");
            return(MPI_ERR_UNKNOWN );

case ov_class:           
case ov_list:           
case ov_cs_list:           
case ov_magic_colon:           
case ov_built_in_function:       
case ov_user_defined_function:       
case ov_dynamically_linked_function:   
case ov_function_handle:       
case ov_inline_function:       
case ov_float_diagonal_matrix:   
case ov_float_complex_diagonal_matrix:   
case ov_diagonal_matrix:   
case ov_complex_diagonal_matrix:   
case ov_permutation_matrix:           
case ov_null_matrix:               
case ov_null_string:               
case ov_null_sq_string:           

    default:        printf("MPI_Recv: unsupported class %s\n",
                    ov.type_name().c_str());
            return(MPI_ERR_UNKNOWN );
  }
}




DEFUN_DLD(MPI_Recv,args,nargout, "MPI_Recv receive  any Octave datatype into contiguous memory using openmpi library even over an hetherogeneous cluster i.e 32 bits CPUs and 64 bits CPU \n")
{
     octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 3)
    {
      error ("expecting 3 input arguments");
      return retval;
    }

  if (error_state)
    return retval;

     int source = args(0).int_value();    
  if (error_state)
    {
      error ("expecting first argument to be an integer");
      return retval;
    }
 int mytag = args(1).int_value();
  if (error_state)
    {
      error ("expecting second argument to be an integer");
      return retval;
    }

  if (!simple_type_loaded)
    {
      simple::register_type ();
      simple_type_loaded = true;
      mlock ();
    }

	if (args(2).type_id()!=simple::static_type_id()){
		
		error("Please enter octave comunicator object!");
		return octave_value(-1);
	}

	const octave_base_value& rep = args(2).get_rep();
        const simple& B = ((const simple &)rep);
        MPI_Comm comm = ((const simple&) B).comunicator_value ();


     octave_value result;
     int info = recv_class (comm, result,source, mytag );
     comm= NULL;
     retval(1) = info;
//       printf("info on recv_class=%i\n",info);
     retval(0) = result;
     return retval;
   
}
