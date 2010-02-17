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




#include "simple.h"
// set it to 0 if you are using 3.3.50+
#define HAVE_OCTAVE_324 =1
#include <ov-cell.h>    // avoid errmsg "cell -- incomplete datatype"
#include <oct-map.h>    // avoid errmsg "Oct.map -- invalid use undef type"
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



int send_class( MPI_Comm comm, octave_value ov,  ColumnVector rankrec, int mytag);        /* along the datatype */

int send_string(int t_id, MPI_Comm comm, std::string  oi8,ColumnVector rankrec, int mytag);

int send_cell( MPI_Comm comm, Cell cell, ColumnVector rankrec, int mytag);
int send_struct(MPI_Comm comm, Octave_map map,ColumnVector rankrec, int mytag);


template <class Any>
int send_scalar(int t_id, MPI_Comm comm, std::complex<Any> d, ColumnVector rankrec, int mytag);

template <class Any>	
int send_scalar(int t_id, MPI_Comm comm, Any d, ColumnVector rankrec, int mytag);

int send_range(int t_id, MPI_Comm comm, Range range,ColumnVector rankrec, int mytag);


int send_matrix(int t_id, MPI_Comm comm, octave_value myO, ColumnVector rankrec, int mytag);


int send_sp_mat(int t_id,MPI_Comm comm, octave_value MyOv ,ColumnVector rankrec, int mytag  );

// template specialization for complex case

template <class Any>
int send_scalar(int t_id, MPI_Comm comm, std::complex<Any> d, ColumnVector rankrec, int mytag){        
  int info;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(std::complex<Any>,Deco,2);
  Deco[0] = real(d);
  Deco[1] = imag(d);
  // Most of scalars are real not complex
  MPI_Datatype TSnd;
  switch (t_id) {
		  TSnd = MPI_DOUBLE;
		  TSnd = MPI_FLOAT;
		}
      for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
      {
	  info = MPI_Send(&t_id, 1, MPI_INT,  rankrec(i), tanktag[0], comm);
	  if (info !=MPI_SUCCESS) return info;
	  info = MPI_Send((&Deco), 2,TSnd, rankrec(i), tanktag[1], comm);
	  if (info !=MPI_SUCCESS) return info;
      }

   return(info);
}


template <class Any>
int send_scalar(int t_id, MPI_Comm comm, Any d, ColumnVector rankrec, int mytag){        
  int info;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  // Most of scalars are real not complex
  MPI_Datatype TSnd;
  switch (t_id) {
		case ov_scalar:  		TSnd = MPI_DOUBLE;
		case ov_bool: 			TSnd = MPI_INT;
		case ov_float_scalar:   	TSnd = MPI_FLOAT;
		case ov_int8_scalar:   		TSnd = MPI_BYTE;
		case ov_int16_scalar:   	TSnd = MPI_SHORT;
		case ov_int32_scalar:   	TSnd = MPI_INT;
		case ov_int64_scalar:   	TSnd = MPI_LONG_LONG;
		case ov_uint8_scalar:  		TSnd = MPI_UNSIGNED_CHAR;
		case ov_uint16_scalar:  	TSnd = MPI_UNSIGNED_SHORT;
		case ov_uint32_scalar:  	TSnd = MPI_UNSIGNED;
		case ov_uint64_scalar:  	TSnd = MPI_UNSIGNED_LONG_LONG;
                }
  
      for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
      {
	  info = MPI_Send(&t_id, 1, MPI_INT,  rankrec(i), tanktag[0], comm);
	  if (info !=MPI_SUCCESS) return info;
	  info = MPI_Send((&d), 1,TSnd, rankrec(i), tanktag[1], comm);
	  if (info !=MPI_SUCCESS) return info;
      }

   return(info);
}

int send_range(int t_id, MPI_Comm comm, Range range,ColumnVector rankrec, int mytag){        /* put base,limit,incr,nelem */
/*-------------------------------*/        /* just 3 doubles + 1 int */
// octave_range (double base, double limit, double inc)
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(double,d,3);
  d[0]= range.base();
  d[1]= range.limit();
  d[2]= range.inc();
  int info;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
    info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
    if (info !=MPI_SUCCESS) return info;
    info = MPI_Send(d, 3, MPI_INT, rankrec(i), tanktag[1], comm);
    if (info !=MPI_SUCCESS) return info;
  }
   
return(MPI_SUCCESS);
}


int send_matrix(int t_id,MPI_Comm comm, octave_value myOv ,ColumnVector rankrec, int mytag){       
  int info;
  int nitem;
  dim_vector dv;
  OCTAVE_LOCAL_BUFFER(int,tanktag,6);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  tanktag[2] = mytag+2;
  tanktag[3] = mytag+3;
  tanktag[4] = mytag+4;
  tanktag[5] = mytag+5;

  int nd;

  MPI_Datatype TSnd;
		if (t_id == ov_matrix) 
		{  
		TSnd = MPI_DOUBLE;
		NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		  for (octave_idx_type i=0; i<nd; i++)
		  {
		    dimV[i] = dv(i) ;
		  }
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(double,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		
		}
		else if (t_id == ov_complex_matrix)
		{  
		TSnd = MPI_DOUBLE;
		ComplexNDArray myNDA = myOv.complex_array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		  for (octave_idx_type i=0; i<nd; i++)
		  {
		    dimV[i] = dv(i) ;
		  }
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(double,LBNDA1,nitem);
		OCTAVE_LOCAL_BUFFER(double,LBNDA2,nitem);

		  for (octave_idx_type i=0; i<nitem; i++)
		  {
		      LBNDA1[i] = real(myNDA(i));
		      LBNDA2[i] = imag(myNDA(i));
		  }

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA1,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA2,1,fortvec,rankrec(i),tanktag[5],comm);
		      if (info !=MPI_SUCCESS) return info;

		  }		

		}
		else if (t_id==ov_bool_matrix)
		{  
		TSnd = MPI_INT;
		boolNDArray myNDA = myOv.bool_array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		  for (octave_idx_type i=0; i<nd; i++)
		  {
		    dimV[i] = dv(i) ;
		  }
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(bool,LBNDA,nitem);
    

		  for (octave_idx_type i=0; i<nitem; i++)
		  {
		      LBNDA[i] = myNDA(i) ;
		  }

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id==ov_float_matrix)
		{  
		  TSnd = MPI_FLOAT;
		  FloatNDArray myNDA = myOv.float_array_value();
		  nitem = myNDA.nelem();
		  dv = myNDA.dims();
		  nd = myNDA.ndims();
		  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		  for (octave_idx_type i=0; i<nd; i++)
		  {
		    dimV[i] = dv(i) ;
		  }
		  // Now create the contiguous derived datatype for the dim vector
		  MPI_Datatype dimvec;
		  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		  MPI_Type_commit(&dimvec);
		  
		  OCTAVE_LOCAL_BUFFER(float,LBNDA,nitem);
      

		  for (octave_idx_type i=0; i<nitem; i++)
		  {
		      LBNDA[i] = myNDA(i) ;
		  }

		  // Now create the contiguous derived datatype
		  MPI_Datatype fortvec;
		  MPI_Type_contiguous(nitem,TSnd, &fortvec);
		  MPI_Type_commit(&fortvec);
		  
		    for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		    {  
			    info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
			if (info !=MPI_SUCCESS) return info;
			    info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
			if (info !=MPI_SUCCESS) return info;
			    info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
			if (info !=MPI_SUCCESS) return info;
			    info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
			if (info !=MPI_SUCCESS) return info;
			info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
			if (info !=MPI_SUCCESS) return info;
		    }		

		
		}
		else if (t_id==ov_float_complex_matrix)
		{  
		  FloatComplexNDArray myNDA = myOv.float_complex_array_value();
		  nitem = myNDA.nelem();
		  dv = myNDA.dims();
		  nd = myNDA.ndims();
		  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		  for (octave_idx_type i=0; i<nd; i++)
		  {
		    dimV[i] = dv(i) ;
		  }
		  // Now create the contiguous derived datatype for the dim vector
		  MPI_Datatype dimvec;
		  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		  MPI_Type_commit(&dimvec);
		  
		  OCTAVE_LOCAL_BUFFER(float,LBNDA1,nitem);
		  OCTAVE_LOCAL_BUFFER(float,LBNDA2,nitem);

		  for (octave_idx_type i=0; i<nitem; i++)
		  {
		      LBNDA1[i] = real(myNDA(i));
		      LBNDA2[i] = imag(myNDA(i));
		  }

		  // Now create the contiguous derived datatype
		  MPI_Datatype fortvec;
		  MPI_Type_contiguous(nitem,TSnd, &fortvec);
		  MPI_Type_commit(&fortvec);
		  
		    for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		    {  
			    info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
			if (info !=MPI_SUCCESS) return info;
			    info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
			if (info !=MPI_SUCCESS) return info;
			    info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
			if (info !=MPI_SUCCESS) return info;
			    info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
			if (info !=MPI_SUCCESS) return info;
			info =  MPI_Send(LBNDA1,1,fortvec,rankrec(i),tanktag[4],comm);
			if (info !=MPI_SUCCESS) return info;
			info =  MPI_Send(LBNDA2,1,fortvec,rankrec(i),tanktag[5],comm);
			if (info !=MPI_SUCCESS) return info;
		    }		

		}
		else if(t_id==ov_int8_matrix)
		{   
		TSnd = MPI_BYTE;
		TSnd = MPI_FLOAT;
		int8NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_int8,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		
		
		}
		else if(t_id== ov_int16_matrix)
		{  
		TSnd = MPI_SHORT;
		int16NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_int16,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id== ov_int32_matrix)
		{   
		TSnd = MPI_INT;
		int32NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_int32,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id== ov_int64_matrix)
		{   
		TSnd = MPI_LONG_LONG;
		int64NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_int64,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id== ov_uint8_matrix)
		{  
		TSnd = MPI_UNSIGNED_CHAR;
		uint8NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_uint8,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id== ov_uint16_matrix) 
		{  
		TSnd = MPI_UNSIGNED_SHORT;
		uint16NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_uint16,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id==ov_uint32_matrix) 
		{   
		TSnd = MPI_UNSIGNED;
		uint32NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		for (octave_idx_type i=0; i<nd; i++)
		{
		  dimV[i] = dv(i) ;
		}
		// Now create the contiguous derived datatype for the dim vector
		MPI_Datatype dimvec;
		MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		MPI_Type_commit(&dimvec);
		
		OCTAVE_LOCAL_BUFFER(octave_uint32,LBNDA,nitem);
    

		for (octave_idx_type i=0; i<nitem; i++)
		{
		    LBNDA[i] = myNDA(i) ;
		}

		// Now create the contiguous derived datatype
		MPI_Datatype fortvec;
		MPI_Type_contiguous(nitem,TSnd, &fortvec);
		MPI_Type_commit(&fortvec);
		
		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {  
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }		

		}
		else if(t_id== ov_uint64_matrix)
		{  
		    TSnd = MPI_UNSIGNED_LONG_LONG;
		    uint64NDArray myNDA = myOv.array_value();
		    nitem = myNDA.nelem();
		    dv = myNDA.dims();
		    nd = myNDA.ndims();
		    OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		    for (octave_idx_type i=0; i<nd; i++)
		    {
		      dimV[i] = dv(i) ;
		    }
		    // Now create the contiguous derived datatype for the dim vector
		    MPI_Datatype dimvec;
		    MPI_Type_contiguous(nd,MPI_INT, &dimvec);
		    MPI_Type_commit(&dimvec);
		    
		    OCTAVE_LOCAL_BUFFER(octave_uint64,LBNDA,nitem);
	

		    for (octave_idx_type i=0; i<nitem; i++)
		    {
			LBNDA[i] = myNDA(i) ;
		    }

		    // Now create the contiguous derived datatype
		    MPI_Datatype fortvec;
		    MPI_Type_contiguous(nitem,TSnd, &fortvec);
		    MPI_Type_commit(&fortvec);
		    
		      for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		      {  
			      info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
			  if (info !=MPI_SUCCESS) return info;
			      info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
			  if (info !=MPI_SUCCESS) return info;
			      info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
			  if (info !=MPI_SUCCESS) return info;
			      info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
			  if (info !=MPI_SUCCESS) return info;
			  info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
			  if (info !=MPI_SUCCESS) return info;
		      }		

                 }

 
return(info);
}


int send_sp_mat(int t_id,MPI_Comm comm, octave_value MyOv ,ColumnVector rankrec, int mytag  ){
int info;
OCTAVE_LOCAL_BUFFER(int,tanktag,6);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
tanktag[5] = mytag+5;

// printf("I will send this t_id=%i\n",t_id);
MPI_Datatype TSnd;
  
		if(t_id == ov_sparse_bool_matrix)
		 {  
		  TSnd = MPI_INT;
		  OCTAVE_LOCAL_BUFFER(int,s,3); 
		  SparseBoolMatrix m = MyOv.sparse_bool_matrix_value();
		  s[0]= m.rows();
		  s[1]= m.cols();
		  s[2]= m.capacity();

		  // Create a contiguous derived datatype
		  MPI_Datatype sintsparse;
		  MPI_Type_contiguous(3,MPI_INT, &sintsparse);
		  MPI_Type_commit(&sintsparse);


		  MPI_Datatype rowindex;
		  MPI_Type_contiguous(m.capacity(),MPI_INT, &rowindex);
		  MPI_Type_commit(&rowindex);

		  MPI_Datatype columnindex;
		  MPI_Type_contiguous(m.cols()+1,MPI_INT, &columnindex);
		  MPI_Type_commit(&columnindex);

		  OCTAVE_LOCAL_BUFFER( int ,sridx,m.capacity());
		  OCTAVE_LOCAL_BUFFER( int ,scidx,m.cols()+1);
		  
		  for (octave_idx_type ix = 0; ix < m.cols()+1; ix++)
		  {
		  scidx[ix]= m.cidx(ix);   
		  }
		  OCTAVE_LOCAL_BUFFER(bool ,sdata,m.capacity());
		  // Fill them with their respective value
		  for (octave_idx_type ix = 0; ix < m.capacity(); ix++)
		  {
		      sdata[ix]= m.data(ix);
		      sridx[ix]= m.ridx(ix);
		  }
		  MPI_Datatype numnnz;
		  MPI_Type_contiguous(m.capacity(),TSnd, &numnnz);
		  MPI_Type_commit(&numnnz);

		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(s, 1, sintsparse, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sridx,1,rowindex,rankrec(i),tanktag[2],comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(scidx,1,columnindex,rankrec(i),tanktag[3],comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sdata,1,numnnz,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }
		 }
		else if (t_id == ov_sparse_matrix)
		 { 
		  TSnd = MPI_DOUBLE;
		  SparseMatrix m = MyOv.sparse_matrix_value();
		  OCTAVE_LOCAL_BUFFER(int,s,3);  
		  s[0]= m.rows();
		  s[1]= m.cols();
		  s[2]= m.capacity();

		  // Create a contiguous derived datatype
		  MPI_Datatype sintsparse;
		  MPI_Type_contiguous(3,MPI_INT, &sintsparse);
		  MPI_Type_commit(&sintsparse);


		  MPI_Datatype rowindex;
		  MPI_Type_contiguous(m.capacity(),MPI_INT, &rowindex);
		  MPI_Type_commit(&rowindex);

		  MPI_Datatype columnindex;
		  MPI_Type_contiguous(m.cols()+1,MPI_INT, &columnindex);
		  MPI_Type_commit(&columnindex);

		  OCTAVE_LOCAL_BUFFER( int ,sridx,m.capacity());
		  OCTAVE_LOCAL_BUFFER( int ,scidx,m.cols()+1);
		  
		  for (octave_idx_type ix = 0; ix < m.cols()+1; ix++)
		  {
		  scidx[ix]= m.cidx(ix);   
		  }
		  OCTAVE_LOCAL_BUFFER(double ,sdata,m.capacity());
		  // Fill them with their respective value
		  for (octave_idx_type ix = 0; ix < m.capacity(); ix++)
		  {
		      sdata[ix]= m.data(ix);
		      sridx[ix]= m.ridx(ix);
		  }
		  MPI_Datatype numnnz;
		  MPI_Type_contiguous(m.capacity(),TSnd, &numnnz);
		  MPI_Type_commit(&numnnz);

		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
// 			  printf("This is info for sending t_id =%i\n",info);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(s, 1, sintsparse, rankrec(i), tanktag[1], comm);
// 			  printf("This is info for sending s=%i\n",info);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sridx,1,rowindex,rankrec(i),tanktag[2],comm);
// 		      printf("This is info for sending sridx=%i\n",info);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(scidx,1,columnindex,rankrec(i),tanktag[3],comm);
// 		      printf("This is info for sending scidx=%i\n",info);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sdata,1,numnnz,rankrec(i),tanktag[4],comm);
// 		      printf("This is info for sending sdata=%i\n",info);
		      if (info !=MPI_SUCCESS) return info;
		  }		
		 }
		else if (t_id == ov_sparse_complex_matrix)
		 { 
		  TSnd = MPI_DOUBLE;
		  SparseComplexMatrix m = MyOv.sparse_complex_matrix_value();
		  OCTAVE_LOCAL_BUFFER(int,s,3);  
		  s[0]= m.rows();
		  s[1]= m.cols();
		  s[2]= m.capacity();

		  // Create a contiguous derived datatype
		  MPI_Datatype sintsparse;
		  MPI_Type_contiguous(3,MPI_INT, &sintsparse);
		  MPI_Type_commit(&sintsparse);


		  MPI_Datatype rowindex;
		  MPI_Type_contiguous(m.capacity(),MPI_INT, &rowindex);
		  MPI_Type_commit(&rowindex);

		  MPI_Datatype columnindex;
		  MPI_Type_contiguous(m.cols()+1,MPI_INT, &columnindex);
		  MPI_Type_commit(&columnindex);

		  OCTAVE_LOCAL_BUFFER( int ,sridx,m.capacity());
		  OCTAVE_LOCAL_BUFFER( int ,scidx,m.cols()+1);
		  
		  for (octave_idx_type ix = 0; ix < m.cols()+1; ix++)
		  {
		  scidx[ix]= m.cidx(ix);   
		  }
		  OCTAVE_LOCAL_BUFFER(double ,sdata1,m.capacity());
		  OCTAVE_LOCAL_BUFFER(double ,sdata2,m.capacity());
		  // Fill them with their respective value
		  for (octave_idx_type ix = 0; ix < m.capacity(); ix++)
		  {
		      sdata1[ix]= real(m.data(ix));
		      sdata2[ix]= imag(m.data(ix));
		      sridx[ix]= m.ridx(ix);
		  }
		  MPI_Datatype numnnz;
		  MPI_Type_contiguous(m.capacity(),TSnd, &numnnz);
		  MPI_Type_commit(&numnnz);

		  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
		  {
			  info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(s, 1, sintsparse, rankrec(i), tanktag[1], comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sridx,1,rowindex,rankrec(i),tanktag[2],comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(scidx,1,columnindex,rankrec(i),tanktag[3],comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sdata1,1,numnnz,rankrec(i),tanktag[4],comm);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(sdata1,1,numnnz,rankrec(i),tanktag[5],comm);
		      if (info !=MPI_SUCCESS) return info;
		  }
		 }
return(info);
}
int send_string(int t_id, MPI_Comm comm, std::string  oi8,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = oi8.length();
  int tanktag[3];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  tanktag[2] = mytag+2;
//    OCTAVE_LOCAL_BUFFER(char,i8,nitem+1);
    char i8[nitem+1];
  strcpy(i8, oi8.c_str());

// Here we declare a contiguous derived datatype
// Create a contiguous datatype for the fortranvec
MPI_Datatype fortvec;
MPI_Type_contiguous(nitem+1,MPI_CHAR, &fortvec);
MPI_Type_commit(&fortvec);



  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       printf("I am sending to %d \n",rankrec(i));   
//           printf("Sending block with tag to %i \n",mytag);
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), mytag, comm);
      if (info !=MPI_SUCCESS) return info;
//       printf("Sending type of object  %i \n",t_id);   
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("Sending nitem  %i \n",nitem);   
      if (info !=MPI_SUCCESS) return info;
      info =  MPI_Send(&i8,1,fortvec,rankrec(i),tanktag[2],comm);
//           printf("Info for sending fortvec  %i \n",info);   
      if (info !=MPI_SUCCESS) return info;
  }

    return(info);

}
int send_cell(MPI_Comm comm, Cell cell, ColumnVector rankrec, int mytag){    /* we first store nelems and then */
/*----------------------------*/    /* recursively the elements themselves */

// Lists of items to send
// type_id to identify octave_value
// n for the cell capacity
// nd for number of dimensions
// dimvec derived datatype
// item of cell
  int t_id = ov_cell;
  int n = cell.capacity();
  int info;
  int tanktag[5];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  tanktag[2] = mytag+2;
  tanktag[3] = mytag+3;
  tanktag[4] = mytag+4;
  int newtag = tanktag[4];
  dim_vector    vdim   = cell. dims();
  int nd = cell.ndims();

// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = vdim(i) ;
 }

  // Now create the contiguous derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);


// Now start the big loop

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
//   	  printf("I have sent the t_id of cell .. and this the flag =%i \n",info);
      if (info !=MPI_SUCCESS) return info;
// send cell capacity
          info = MPI_Send(&n, 1, MPI_INT, rankrec(i), tanktag[1], comm);
/*           printf("I have sent the capacity of the cell .. and this the flag =%i \n",info);
  	  printf(".. and this the value of capacity =%i \n",n);*/
      if (info !=MPI_SUCCESS) return info;
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
/*           printf("I have sent the capacity of the number of dimensions .. and this the flag =%i \n",info);
           printf("I have sent the value of nd =%i \n",nd);*/
      if (info !=MPI_SUCCESS) return info;
// send the dim vector
      info =  MPI_Send(dimV,1,dimvec,rankrec(i),tanktag[3],comm);
//         printf("I have sent the dim_vector .. and this the flag =%i \n",info);
      if (info !=MPI_SUCCESS) return info;
  }

int cap;
// Now focus on every single octave_value
         for (octave_idx_type i=0; i<n; i++){
// 	     printf("I am processing octave_value number %i\n",i);
             octave_value ov = cell.data()[i];
	     cap =ov.capacity();
	     info = MPI_Send(&cap, 1, MPI_INT, rankrec(i), newtag, comm);
//   	     printf("I have sent the capacity .. and this the flag = %i\n",info);
	     if (info !=MPI_SUCCESS) return info;
             newtag = newtag +ov.capacity();
	     info=send_class(comm,ov,rankrec,newtag);
//                printf("I have sent the octave_value inside the cell .. and this the flag = %i\n",info);
// 	       printf("I have sent the octave_value inside the cell  = %f\n",ov.scalar_value());
// 	       printf("I have sent NEWTAG  = %i\n",newtag);
// 	       printf("I have sent NEWTAG+1  = %i\n",newtag+1);
	     if (info !=MPI_SUCCESS) return info;
					    }
					    


  return(info); 


}

int send_struct(MPI_Comm comm, Octave_map map,ColumnVector rankrec, int mytag){        /* we store nkeys, */

int t_id = ov_struct;
int n = map.nfields(); 
int info;
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag; //t-id
  tanktag[1] = mytag+1; // n
int tagcap = mytag+2;
int   ntagkey = mytag+3; // string

// Create 3 contiguous derived datatype
// one for dim_vector struc_dims

  dim_vector struc_dims = map.dims();    // struct array dimensions (ND)
  dim_vector conts_dims;        // each key stores ND field-values


// Now we start the big loop
   for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
   {
           info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
/*  	   printf("I have sent % i \n",t_id);
  	   printf("with info = % i \n",info);*/
	   if (info !=MPI_SUCCESS) return info;
     info = MPI_Send(&n,1,MPI_INT,rankrec(i),tanktag[1],comm);
     if (info !=MPI_SUCCESS) return info;/**/
//       printf("I have sent n with info = % i \n",info);
// // This is to avoid confusion between tags of strings and tags of Cells
   int   ntagCell = ntagkey+1;
    Octave_map::const_iterator p = map.begin();    // iterate through keys(fnames)
   int scap;
   for (octave_idx_type i=0; p!=map.end(); p++, i++)
    {
    std::string        key = map.key     (p);    // field name
    Cell               conts = map.contents(p);    // Cell w/ND contents
    conts_dims = conts.dims();        /* each elemt should have same ND */
    if (struc_dims != conts_dims){
        printf("MPI_Send: inconsistent map dims\n"); return(MPI_ERR_UNKNOWN);
				}
    // Sending capacity of octave_cell
    scap = conts.capacity(); 
    info = MPI_Send(&scap,1,MPI_INT,rankrec(i),tagcap,comm);
//     printf("I have sent capacity of octave cell with info = % i \n",info);
   if (info !=MPI_SUCCESS) return info;
    tagcap = tagcap+1;
    ntagkey = ntagkey + 3;
    info =send_class(comm, key,rankrec,ntagkey);
//     printf("I have sent class with info = % i \n",info);
   
    if (info !=MPI_SUCCESS) return info;
    
    // Sending Cell
    ntagCell = ntagCell + conts.capacity();
    info =send_class(comm, conts,rankrec,ntagCell);
//     printf("I have sent Cell with info = % i \n",info);
   if (info !=MPI_SUCCESS) return info;
    }

      if (n != map.nfields()){printf("MPI_Send: inconsistent map length\n");return(MPI_ERR_UNKNOWN);}


    }

return(info);
}

int send_class(MPI_Comm comm, octave_value ov, ColumnVector rankrec,int mytag){    /* varname-strlength 1st, dims[ndim] */
/*----------------------------------*/    /* and then appropriate specific info */
  int t_id = ov.type_id();

  switch (t_id) {
      // range
      case ov_range:    		return(send_range  (t_id, comm, ov.range_value(),rankrec,mytag));
      // scalar
      case ov_scalar:    	 	return(send_scalar (t_id, comm, ov.scalar_value(),rankrec,mytag));
      case ov_int8_scalar:   		return(send_scalar (t_id, comm, ov.int8_scalar_value(),rankrec,mytag));
      case ov_int16_scalar:   		return(send_scalar (t_id, comm, ov.int16_scalar_value(),rankrec,mytag));
      case ov_int32_scalar:   		return(send_scalar (t_id, comm, ov.int32_scalar_value(),rankrec,mytag));
      case ov_int64_scalar:   		return(send_scalar (t_id, comm, ov.int64_scalar_value(),rankrec,mytag));
      case ov_uint8_scalar:  		return(send_scalar (t_id, comm, ov.uint8_scalar_value(),rankrec,mytag));
      case ov_uint16_scalar:  		return(send_scalar (t_id, comm, ov.uint16_scalar_value(),rankrec,mytag));
      case ov_uint32_scalar:  		return(send_scalar (t_id, comm, ov.uint32_scalar_value(),rankrec,mytag));
      case ov_uint64_scalar:  		return(send_scalar (t_id, comm, ov.uint64_scalar_value(),rankrec,mytag));
      case ov_bool:			return(send_scalar (t_id, comm, ov.int_value(),rankrec,mytag));
      case ov_float_scalar:    		return(send_scalar (t_id, comm, ov.float_value (),rankrec,mytag));
      case ov_complex_scalar: 		return(send_scalar (t_id, comm, ov.complex_value(),rankrec,mytag));
      case ov_float_complex_scalar: 		return(send_scalar (t_id, comm, ov.float_complex_value(),rankrec,mytag));
      // matrix
      case ov_matrix:    	 	return(send_matrix(t_id, comm, ov,rankrec,mytag)); 
      case ov_bool_matrix:		return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_int8_matrix:    	 	return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_int16_matrix:    	 	return(send_matrix(t_id, comm, ov,rankrec,mytag));        
      case ov_int32_matrix:    	 	return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_int64_matrix:    	 	return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_uint8_matrix:    	 	return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_uint16_matrix:    	return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_uint32_matrix:    	return(send_matrix(t_id, comm, ov,rankrec,mytag));
      case ov_uint64_matrix:    	return(send_matrix(t_id, comm, ov,rankrec,mytag));
//       case ov_char_matrix:    		return(send_matrix(t_id, comm, ov,rankrec,mytag));
//       complex matrix
      case ov_complex_matrix:           return(send_matrix(t_id, comm,ov,rankrec,mytag));
      case ov_float_complex_matrix:  	return(send_matrix(t_id, comm,ov,rankrec,mytag)); 
//       sparse matrix
      case ov_sparse_bool_matrix:		  return(send_sp_mat(t_id, comm,ov,rankrec,mytag));
      case ov_sparse_matrix:			  return(send_sp_mat(t_id,comm,ov,rankrec,mytag));	
      case ov_sparse_complex_matrix:  	return(send_sp_mat(t_id,comm,ov,rankrec,mytag));	
      
      case ov_string:    		return(send_string (t_id,comm, ov.string_value(),rankrec,mytag));
      case ov_sq_string:  		return(send_string (t_id,comm, ov.string_value(),rankrec,mytag));
      case ov_struct:    		return(send_struct (comm, ov.map_value    (),rankrec,mytag));
      case ov_cell:    	 	 	return(send_cell   (comm, ov.cell_value   (),rankrec,mytag));
      case ov_unknown:    		printf("MPI_Send: unknown class\n");
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
      default:        printf("MPI_Send: unsupported class %s\n",
                    ov.type_name().c_str());
            return(MPI_ERR_UNKNOWN );      
      
  }
}



DEFUN_DLD(MPI_Send,args,nargout, "MPI_Send sends  any octave_value  into contiguous memory using openmpi library even over an hetherogeneous cluster i.e 32 bits CPUs and 64 bits CPU \n")
{
     octave_value retval;

  int nargin = args.length ();
  if (nargin != 4 )
    {
      error ("expecting 4 input arguments");
      return retval;
    }

  if (error_state)
    return retval;

     ColumnVector tankrank = args(1).column_vector_value();    
  
  if (error_state)
    {
      error ("expecting second argument to be a column vector");
      return retval;
    }
     int mytag = args(2).int_value();    
  if (error_state)
    {
      error ("expecting third vector argument to be an integer value");
      return retval;
    }



  if (!simple_type_loaded)
    {
      simple::register_type ();
      simple_type_loaded = true;
      mlock ();
    }

	if (args(3).type_id()!=simple::static_type_id()){
		
		error("Please enter octave comunicator object!");
		return octave_value(-1);
	}

	const octave_base_value& rep = args(3).get_rep();
        const simple& B = ((const simple &)rep);
        MPI_Comm comm = ((const simple&) B).comunicator_value ();
     int info = send_class (comm, args(0), tankrank, mytag);
     comm= NULL;
     retval=info;
     return retval;
   
}

