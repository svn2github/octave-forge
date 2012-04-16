// Copyright (C) 2009 Riccardo Corradini <riccardocorradini@yahoo.it>
// Copyright (C) 2009 VZLU Prague
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

#include "simple.h"
#include <ov-cell.h>    // avoid errmsg "cell -- incomplete datatype"
#include <oct-map.h>    // avoid errmsg "Oct.map -- invalid use undef type"


/*----------------------------------*/        /* forward declaration */



int send_class( MPI_Comm comm, octave_value ov,  ColumnVector rankrec, int mytag);        /* along the datatype */

int send_string(int t_id, MPI_Comm comm, std::string  oi8,ColumnVector rankrec, int mytag);

int send_cell(int t_id, MPI_Comm comm, Cell cell, ColumnVector rankrec, int mytag);
int send_struct(int t_id, MPI_Comm comm, Octave_map map,ColumnVector rankrec, int mytag);


template <class Any>
int send_scalar(int t_id, MPI_Datatype TSnd,MPI_Comm comm, std::complex<Any> d, ColumnVector rankrec, int mytag);


template <class Any>
int send_scalar(int t_id, MPI_Datatype TSnd, MPI_Comm comm, Any d, ColumnVector rankrec, int mytag);

int send_range(int t_id, MPI_Comm comm, Range range,ColumnVector rankrec, int mytag);

int send_matrix(int t_id,  MPI_Datatype TSnd,MPI_Comm comm, octave_value myOv ,ColumnVector rankrec, int mytag);


int send_sp_mat(int t_id, MPI_Datatype TSnd ,MPI_Comm comm, octave_value MyOv ,ColumnVector rankrec, int mytag  );

// template specialization for complex case

template <class Any>
int send_scalar(int t_id,MPI_Datatype TSnd ,MPI_Comm comm, std::complex<Any> d, ColumnVector rankrec, int mytag){        
  int info;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(std::complex<Any>,Deco,2);
  Deco[0] = real(d);
  Deco[1] = imag(d);

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
int send_scalar(int t_id, MPI_Datatype TSnd, MPI_Comm comm, Any d, ColumnVector rankrec, int mytag){        
  int info;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  
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
/*-------------------------------*/        /* just 2 doubles + 1 int */
  OCTAVE_LOCAL_BUFFER(int,tanktag,3);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  tanktag[2] = mytag+2;
  OCTAVE_LOCAL_BUFFER(double,d,3);
//   Range  (double  b, double  l, double  i)
  d[0]= range.base();
  d[1]= range.limit();
  d[2]= range.inc();
  int nele = range.nelem();
  int info;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
    info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
    if (info !=MPI_SUCCESS) return info;
    info = MPI_Send(d, 2, MPI_DOUBLE, rankrec(i), tanktag[1], comm);
    if (info !=MPI_SUCCESS) return info;
    info = MPI_Send(&nele, 1, MPI_INT, rankrec(i), tanktag[2], comm);
    if (info !=MPI_SUCCESS) return info;
  }
   
return(MPI_SUCCESS);
}


int send_matrix(int t_id,  MPI_Datatype TSnd,MPI_Comm comm, octave_value myOv ,ColumnVector rankrec, int mytag){       
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
		if (TSnd == MPI_DOUBLE and myOv.is_real_type())
		{  
		NDArray myNDA = myOv.array_value();
		nitem = myNDA.nelem();
		dv = myNDA.dims();
		nd = myNDA.ndims();
		OCTAVE_LOCAL_BUFFER(int,dimV,nd);
		  for (octave_idx_type i=0; i<nd; i++)
		  {
		    dimV[i] = dv(i) ;
// 		    printf("\ndimV[i] = %i\n",dimV[i]);
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
// 			  printf("\n info  for t_id is %i",info);
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
// 			  printf("\n info  for nitem is %i",info);
// 			  printf("\n OK nitem is %i",nitem);  
		      if (info !=MPI_SUCCESS) return info;
			  info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
// 			  printf("\n info  for nd is %i",info);
		      if (info !=MPI_SUCCESS) return info;
// 			  printf("\n processing dim  vector with %i\n",nd);
			  info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
// 			  printf("\n info  for dimV is %i",info);
		      if (info !=MPI_SUCCESS) return info;
		      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
// 			  printf("\n info  for LBNDA is % i",info);
		      if (info !=MPI_SUCCESS) return info;
		  }		
		}
		else if (TSnd == MPI_DOUBLE and myOv.is_complex_type())
		{  
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
		else if (TSnd == MPI_INT and myOv.is_bool_type())
		{  
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
		else if(TSnd == MPI_FLOAT and myOv.is_float_type())
		{  
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
		else if(TSnd == MPI_FLOAT and myOv.is_complex_type())
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
		else if(TSnd == MPI_BYTE and myOv.is_int8_type())
		{   
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
		else if(TSnd == MPI_SHORT and myOv.is_int16_type())
		{  
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
		else if (TSnd == MPI_INT and myOv.is_int32_type())
		{   
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
		else if(TSnd == MPI_LONG_LONG and myOv.is_int64_type())
		{   
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
		else if(TSnd == MPI_UNSIGNED_CHAR and myOv.is_uint8_type()) 
		{  
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
		else if(TSnd == MPI_UNSIGNED_SHORT and myOv.is_uint16_type())
		{  
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
		else if(TSnd == MPI_UNSIGNED and myOv.is_uint32_type())
		{   
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
		else if(TSnd== MPI_UNSIGNED_LONG_LONG and myOv.is_uint64_type())
		{  
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


int send_sp_mat(int t_id, MPI_Datatype TSnd ,MPI_Comm comm, octave_value MyOv ,ColumnVector rankrec, int mytag  ){
int info;
OCTAVE_LOCAL_BUFFER(int,tanktag,6);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
tanktag[5] = mytag+5;

// printf("I will send this t_id=%i\n",t_id);
  
		if(TSnd == MPI_INT and MyOv.is_bool_type())
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
		else if (TSnd == MPI_DOUBLE and MyOv.is_real_type())
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
		else if (TSnd == MPI_DOUBLE and MyOv.is_complex_type())
		 { 
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
int send_cell(int t_id,MPI_Comm comm, Cell cell, ColumnVector rankrec, int mytag){    /* we first store nelems and then */
/*----------------------------*/    /* recursively the elements themselves */

// Lists of items to send
// type_id to identify octave_value
// n for the cell capacity
// nd for number of dimensions
// dimvec derived datatype
// item of cell
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

int send_struct(int t_id,MPI_Comm comm, Octave_map map,ColumnVector rankrec, int mytag){        /* we store nkeys, */

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
  const std::string mystring = ov.type_name();
  MPI_Datatype TSnd;
      // range
      if (mystring == "range")     		return(send_range  (t_id, comm, ov.range_value(),rankrec,mytag));
      // scalar
      if (mystring == "scalar")  {   TSnd = MPI_DOUBLE;	 	return(send_scalar (t_id, TSnd,comm, ov.scalar_value(),rankrec,mytag)); }
      if (mystring == "int8 scalar")  { TSnd = MPI_BYTE;		return(send_scalar (t_id, TSnd,comm, ov.int8_scalar_value(),rankrec,mytag)); }
      if (mystring == "int16 scalar")  { TSnd = MPI_SHORT; 		return(send_scalar (t_id,TSnd ,comm, ov.int16_scalar_value(),rankrec,mytag));}
      if (mystring ==  "int32 scalar")  { TSnd = MPI_INT;		return(send_scalar (t_id, TSnd,comm, ov.int32_scalar_value(),rankrec,mytag));}
      if (mystring ==  "int64 scalar")  { TSnd = MPI_LONG_LONG;		return(send_scalar (t_id,TSnd ,comm, ov.int64_scalar_value(),rankrec,mytag));}
      if (mystring ==  "uint8 scalar")  {	TSnd = MPI_UNSIGNED_CHAR;	return(send_scalar (t_id,TSnd ,comm, ov.uint8_scalar_value(),rankrec,mytag));}
      if (mystring ==  "uint16 scalar")  {	TSnd = MPI_UNSIGNED_SHORT;	return(send_scalar (t_id,TSnd , comm, ov.uint16_scalar_value(),rankrec,mytag));}
      if (mystring ==  "uint32 scalar")  {	TSnd = MPI_UNSIGNED;	return(send_scalar (t_id,TSnd , comm, ov.uint32_scalar_value(),rankrec,mytag));}
      if (mystring == "uint64 scalar")  {	TSnd = MPI_UNSIGNED_LONG_LONG;	return(send_scalar (t_id,TSnd , comm, ov.uint64_scalar_value(),rankrec,mytag));}
      if (mystring ==  "bool")		{TSnd = MPI_INT;	return(send_scalar (t_id,TSnd , comm, ov.int_value(),rankrec,mytag));}
      if (mystring ==  "float scalar")    	{ TSnd = MPI_FLOAT;	return(send_scalar (t_id,TSnd , comm, ov.float_value (),rankrec,mytag));}
      if (mystring ==  "complex scalar") 	{ TSnd = MPI_DOUBLE;	return(send_scalar (t_id,TSnd , comm, ov.complex_value(),rankrec,mytag));}
      if (mystring ==  "float complex scalar")	{ TSnd = MPI_FLOAT; 		return(send_scalar (t_id,TSnd , comm, ov.float_complex_value(),rankrec,mytag));}
      // matrix
      if (mystring ==  "matrix")    	 	{TSnd = MPI_DOUBLE; return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));} 
      if (mystring ==  "bool matrix")		{TSnd = MPI_INT;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "int8 matrix")    	 	{TSnd = MPI_BYTE;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "int16 matrix")    	 	{TSnd = MPI_SHORT;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}        
      if (mystring ==  "int32 matrix")    	 	{TSnd = MPI_INT;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "int64 matrix")   	 	{TSnd = MPI_LONG_LONG;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "uint8 matrix")    	 	{TSnd = MPI_UNSIGNED_CHAR;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "uint16 matrix")    	{TSnd = MPI_UNSIGNED_SHORT;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "uint32 matrix")    	{TSnd = MPI_UNSIGNED;return(send_matrix(t_id,TSnd,comm, ov,rankrec,mytag));}
      if (mystring ==  "uint64 matrix")    	{TSnd = MPI_UNSIGNED_LONG_LONG;return(send_matrix(t_id,TSnd ,comm, ov,rankrec,mytag));}
//       complex matrix
      if (mystring ==  "complex matrix")           {TSnd = MPI_DOUBLE;return(send_matrix(t_id,TSnd,comm,ov,rankrec,mytag));}
      if (mystring ==  "float complex matrix")     {TSnd = MPI_FLOAT;return(send_matrix(t_id,TSnd,comm,ov,rankrec,mytag));} 
//       sparse matrix
      if (mystring ==  "sparse bool matrix")		  {TSnd = MPI_INT;return(send_sp_mat(t_id,TSnd,comm,ov,rankrec,mytag));}
      if (mystring ==  "sparse matrix")			  {TSnd = MPI_DOUBLE;return(send_sp_mat(t_id,TSnd,comm,ov,rankrec,mytag));}	
      if (mystring ==  "sparse complex matrix")  		  {TSnd = MPI_DOUBLE;return(send_sp_mat(t_id,TSnd,comm,ov,rankrec,mytag));}	
      
      if (mystring == "string")    		return(send_string (t_id,comm, ov.string_value(),rankrec,mytag));
      if (mystring == "sq_string")  		return(send_string (t_id,comm, ov.string_value(),rankrec,mytag));
      
      if (mystring ==  "struct")    		return(send_struct (t_id,comm, ov.map_value    (),rankrec,mytag));
      if (mystring ==  "cell")    	 	 	return(send_cell   (t_id,comm, ov.cell_value   (),rankrec,mytag));
      
      if (mystring ==  "<unknown type>")  {  		printf("MPI_Send: unknown class\n");
             return(MPI_ERR_UNKNOWN );
	  } 
      else{
	    printf("MPI_Send: unsupported class %s\n",
                    ov.type_name().c_str());
            return(MPI_ERR_UNKNOWN );
	   } 
      
}
DEFUN_DLD(MPI_Send,args,nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{INFO} =} MPI_Send(@var{VALUE},@var{RANKS},@var{TAG},@var{COMM})\n\
MPI_Send sends  any octave_value  into contiguous memory using openmpi library \n\
even over an heterogeneous cluster i.e 32 bits CPUs and 64 bits CPU.\n\
Returns an integer @var{INFO} to indicate success or failure of octave_value expedition.\n\
 @example\n\
 @group\n\
@var{VALUE} must be an octave variable \n\
@var{RANKS} must be a vector containing the list of rank destination processes \n\
@var{TAG} must be an integer to identify the message by openmpi \n\
@var{COMM} must be an octave communicator object created by MPI_Comm_Load function \n\
@end group\n\
@end example\n\
\n\
@seealso{MPI_Comm_Load,MPI_Init,MPI_Finalize,MPI_Recv}\n\
@end deftypefn")
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
//      printf("\nThis is info for class %i \n",info);
     comm= NULL;
     retval=info;
     return retval;
   
}

