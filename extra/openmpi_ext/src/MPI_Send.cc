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
 * sends most Octave datatypes into contiguous memory
 * using derived datatypes
 * info = MPI_Send(var,rank)
 */

#include "simple.h"

#include <ov-cell.h>    // avoid errmsg "cell -- incomplete datatype"
#include <oct-map.h>    // avoid errmsg "Oct.map -- invalid use undef type"

enum ov_t_id
{

ov_unknown=0,
ov_cell,            // 1
ov_scalar,            // 2
ov_complex_scalar,        // 3
ov_matrix,            // 4
ov_diagonal_matrix,        // 5
ov_complex_matrix,        // 6
ov_complex_diagonal_matrix,        // 7
ov_range,            // 8
ov_bool,            // 9
ov_bool_matrix,            // 10
ov_char_matrix,            // 11
ov_string,            // 12
ov_sq_string,            // 13
ov_int8_scalar,            // 14
ov_int16_scalar,        // 15
ov_int32_scalar,        // 16
ov_int64_scalar,        // 17
ov_uint8_scalar,        // 18
ov_uint16_scalar,        // 19
ov_uint32_scalar,        // 20
ov_uint64_scalar,        // 21
ov_int8_matrix,            // 22
ov_int16_matrix,        // 23
ov_int32_matrix,        // 24
ov_int64_matrix,        // 25
ov_uint8_matrix,        // 26
ov_uint16_matrix,        // 27
ov_uint32_matrix,        // 28
ov_uint64_matrix,        // 29
ov_sparse_bool_matrix,        // 30
ov_sparse_matrix,        // 31
ov_sparse_complex_matrix,    // 32
ov_struct,            // 33
ov_class,            // 34
ov_list,            // 35
ov_cs_list,            // 36
ov_magic_colon,            // 37
ov_built_in_function,        // 38
ov_user_defined_function,    // 39   
ov_dynamically_linked_function,    // 40
ov_function_handle,        // 41
ov_inline_function,        // 42
ov_float_scalar,        // 43
ov_float_complex_scalar,    // 44
ov_float_matrix,        // 45
ov_float_diagonal_matrix,    // 46
ov_float_complex_matrix,    // 47
ov_float_complex_diagonal_matrix,    // 48
ov_permutation_matrix,            // 49
ov_null_matrix,                // 50
ov_null_string,                // 51
ov_null_sq_string,            // 52
};




/*----------------------------------*/        /* forward declaration */



int send_class( MPI_Comm comm, octave_value ov,  ColumnVector rankrec, int mytag);        /* along the datatype */
/*----------------------------------*/    /* to send any octave_value */
int send_scalar( MPI_Comm comm, double d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a double value */
  int info;
  int t_id = ov_scalar;
  int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_DOUBLE, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_float_scalar( MPI_Comm comm, float d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a float value */
  int info;
  int t_id = ov_float_scalar;
  int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_FLOAT, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_i8( MPI_Comm comm, octave_int8 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just an int8 value */
  int info;
  int t_id = ov_int8_scalar;
  int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_BYTE, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_i16( MPI_Comm comm, octave_int16 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just an int16 value */
  int info;
  int t_id = ov_int16_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_SHORT, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_i32( MPI_Comm comm, octave_int32 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just an int32 value */
  int info;
  int t_id = ov_int32_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_INT, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_i64( MPI_Comm comm, octave_int64 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just an int64 value */
  int info;
  int t_id = ov_int64_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_LONG_LONG, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_ui64( MPI_Comm comm, octave_uint64 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a  value */
  int info;
  int t_id = ov_uint64_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_UNSIGNED_LONG_LONG, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_ui32( MPI_Comm comm, octave_uint32 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a value */
  int info;
  int t_id = ov_uint32_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_UNSIGNED, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_ui16( MPI_Comm comm, octave_uint16 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a  value */
  int info;
  int t_id = ov_uint16_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_UNSIGNED_SHORT, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}


int send_ui8( MPI_Comm comm, octave_uint8 d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a value */
  int info;
  int t_id = ov_uint8_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
//   int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_UNSIGNED_CHAR, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}



int send_bool( MPI_Comm comm, int d, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a  value */
  int info;
  int t_id = ov_bool;
  int tanktag[2];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 1,MPI_DOUBLE, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}



int send_complex_scalar( MPI_Comm comm, Complex c, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a value */
  int info;
  int t_id = ov_complex_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(double,d,2);
  d[0] = real(c);
  d[1] = imag(c);
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 2,MPI_DOUBLE, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}

int send_float_complex_scalar( MPI_Comm comm, std::complex<float>  c, ColumnVector rankrec, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a double value */
  int info;
  int t_id = ov_float_complex_scalar;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(float,d,2);
  d[0] = real(c);
  d[1] = imag(c);
  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
      info = MPI_Send((&d), 2,MPI_FLOAT, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
  }
   return(MPI_SUCCESS);
}



int send_string(MPI_Comm comm, std::string  oi8,ColumnVector rankrec, int mytag){        /* directly pvm_pkbyte it, */
/*----------------------------------*/        /* just a char value */
  int info;
  int nitem = oi8.length();
  int tanktag[3];
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  tanktag[2] = mytag+2;
//    OCTAVE_LOCAL_BUFFER(char,i8,nitem+1);
    char i8[nitem+1];
  strcpy(i8, oi8.c_str());
  int t_id = ov_string;

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
// 	  printf("I have sent the t_id of cell .. and this the flag =%i \n",info);
      if (info !=MPI_SUCCESS) return info;
// send cell capacity
          info = MPI_Send(&n, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent the capacity of the cell .. and this the flag =%i \n",info);
// 	  printf(".. and this the value of capacity =%i \n",n);
      if (info !=MPI_SUCCESS) return info;
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//           printf("I have sent the capacity of the number of dimensions .. and this the flag =%i \n",info);
//           printf("I have sent the value of nd =%i \n",nd);
      if (info !=MPI_SUCCESS) return info;
// send the dim vector
      info =  MPI_Send(dimV,1,dimvec,rankrec(i),tanktag[3],comm);
//       printf("I have sent the dim_vector .. and this the flag =%i \n",info);
      if (info !=MPI_SUCCESS) return info;
  }

int cap;
// Now focus on every single octave_value
         for (octave_idx_type i=0; i<n; i++){
             octave_value ov = cell.data()[i];
	     cap =ov.capacity();
	     info = MPI_Send(&cap, 1, MPI_INT, rankrec(i), newtag, comm);
// 	     printf("I have sent the capacity .. and this the flag = %i\n",info);
	     if (info !=MPI_SUCCESS) return info;
             newtag = newtag +ov.capacity();
	     info=send_class(comm,ov,rankrec,newtag);
//              printf("I have sent the octave_value inside the cell .. and this the flag = %i\n",info);
	     if (info !=MPI_SUCCESS) return info;
					    }
					    


  return(info); 


}

/*-----------------------------------*/        /* to pack a struct */
int send_struct(MPI_Comm comm, Octave_map map,ColumnVector rankrec, int mytag){        /* we store nkeys, */

int n = map.nfields(); 
int info;
int t_id=ov_struct;
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
//  	   printf("I have sent % i \n",t_id);
//  	   printf("with info = % i \n",info);
	   if (info !=MPI_SUCCESS) return info;
     info = MPI_Send(&n,1,MPI_INT,rankrec(i),tanktag[1],comm);
     if (info !=MPI_SUCCESS) return info;/**/
//      printf("I have sent n with info = % i \n",info);
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
    if (info !=MPI_SUCCESS) return info;
    tagcap = tagcap+1;
    ntagkey = ntagkey + 3;
    info =send_class(comm, key,rankrec,ntagkey);
    if (info !=MPI_SUCCESS) return info;
    
    // Sending Cell
    ntagCell = ntagCell + conts.capacity();
    info =send_class(comm, conts,rankrec,ntagCell);
    if (info !=MPI_SUCCESS) return info;
    }

      if (n != map.nfields()){printf("MPI_Send: inconsistent map length\n");return(MPI_ERR_UNKNOWN);}


    }

return(info);
}




int send_sp_mat(MPI_Comm comm, SparseMatrix m ,ColumnVector rankrec, int mytag  ){

int info;
int t_id = ov_sparse_matrix;
int tanktag[5];
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
// octave_idx_type nr = m.rows ();
// octave_idx_type nc = m.cols ();
// octave_idx_type nz = m.nnz ();

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

MPI_Datatype numnnz;
MPI_Type_contiguous(m.capacity(),MPI_DOUBLE, &numnnz);
MPI_Type_commit(&numnnz);


OCTAVE_LOCAL_BUFFER( int ,sridx,m.capacity());
OCTAVE_LOCAL_BUFFER( int ,scidx,m.cols()+1);
OCTAVE_LOCAL_BUFFER( double ,sdata,m.capacity());
// Fill them with their respective value
  for (octave_idx_type ix = 0; ix < m.capacity(); ix++)
  {
      sdata[ix]=m.data(ix);
//       printf("sending %d \n",sdata[ix]);   
      sridx[ix]= m.ridx(ix);
//        printf("sending %i \n",sridx[ix]);   
  }
NDArray buf (dim_vector (m.capacity(), 1));
  for (int ix = 0; ix < m.capacity(); ix++)
  {
      buf(ix)=m.data(ix);
      sdata[ix] = buf(ix);
//     printf("sending buffer %d \n",sdata[ix]);
  }
  for (octave_idx_type ix = 0; ix < m.cols()+1; ix++)
  {
      scidx[ix]= m.cidx(ix);   
//        printf("sending %i \n",scidx[ix]);   

  }



  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
// send the sintsparse vector named s
          info = MPI_Send(s, 1, sintsparse, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector with row indexes
      info =  MPI_Send(sridx,1,rowindex,rankrec(i),tanktag[2],comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector with column indexes
      info =  MPI_Send(scidx,1,columnindex,rankrec(i),tanktag[3],comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector of non zero elements
      info =  MPI_Send(sdata,1,numnnz,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }


return(info);
}





int send_sp_bl_mat(MPI_Comm comm, SparseBoolMatrix m ,ColumnVector rankrec, int mytag  ){

int info;
int t_id = ov_sparse_matrix;
int tanktag[5];
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
// octave_idx_type nr = m.rows ();
// octave_idx_type nc = m.cols ();
// octave_idx_type nz = m.nnz ();

OCTAVE_LOCAL_BUFFER(int,s,3);  
s[0]= m.rows();
s[1]= m.cols();
s[2]= m.capacity();// int n = m.capacity();

// Create a contiguous derived datatype// OCTAVE_LOCAL_BUFFER( double ,data,n);
MPI_Datatype sintsparse;// OCTAVE_LOCAL_BUFFER( int ,ridx,n);
MPI_Type_contiguous(3,MPI_INT, &sintsparse);
MPI_Type_commit(&sintsparse);


MPI_Datatype rowindex;
MPI_Type_contiguous(m.capacity(),MPI_INT, &rowindex);
MPI_Type_commit(&rowindex);

MPI_Datatype columnindex;
MPI_Type_contiguous(m.cols()+1,MPI_INT, &columnindex);
MPI_Type_commit(&columnindex);

MPI_Datatype numnnz;
MPI_Type_contiguous(m.capacity(),MPI_INT, &numnnz);
MPI_Type_commit(&numnnz);


OCTAVE_LOCAL_BUFFER( int ,sridx,m.capacity());
OCTAVE_LOCAL_BUFFER( int ,scidx,m.cols()+1);
OCTAVE_LOCAL_BUFFER( int ,sdata,m.capacity());
// Fill them with their respective value
  for (octave_idx_type ix = 0; ix < m.capacity(); ix++)
  {
      sdata[ix]=m.data(ix);
//       printf("sending %d \n",sdata[ix]);   
      sridx[ix]= m.ridx(ix);
//        printf("sending %i \n",sridx[ix]);   
  }
  for (octave_idx_type ix = 0; ix < m.cols()+1; ix++)
  {
      scidx[ix]= m.cidx(ix);   
//        printf("sending %i \n",scidx[ix]);   

  }



  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
// send the sintsparse vector named s
          info = MPI_Send(s, 1, sintsparse, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector with row indexes
      info =  MPI_Send(sridx,1,rowindex,rankrec(i),tanktag[2],comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector with column indexes
      info =  MPI_Send(scidx,1,columnindex,rankrec(i),tanktag[3],comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector of non zero elements
      info =  MPI_Send(sdata,1,numnnz,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }


return(info);
}

int send_sp_cx_mat(MPI_Comm comm, SparseComplexMatrix m ,ColumnVector rankrec, int mytag  ){

int info;
int t_id = ov_sparse_complex_matrix;
OCTAVE_LOCAL_BUFFER(int,tanktag,6);
// int tanktag[5];
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[4] = mytag+4;
tanktag[5] = mytag+5;

OCTAVE_LOCAL_BUFFER(int,s,3);  
s[0]= m.rows();
s[1]= m.cols();
s[2]= m.capacity();

MPI_Datatype sintsparse;
MPI_Type_contiguous(3,MPI_INT, &sintsparse);
MPI_Type_commit(&sintsparse);


MPI_Datatype rowindex;
MPI_Type_contiguous(m.capacity(),MPI_INT, &rowindex);
MPI_Type_commit(&rowindex);

MPI_Datatype columnindex;
MPI_Type_contiguous(m.cols()+1,MPI_INT, &columnindex);
MPI_Type_commit(&columnindex);

MPI_Datatype numnnz;
MPI_Type_contiguous(m.capacity(),MPI_DOUBLE, &numnnz);
MPI_Type_commit(&numnnz);


OCTAVE_LOCAL_BUFFER( int ,sridx,m.capacity());
OCTAVE_LOCAL_BUFFER( int ,scidx,m.cols()+1);
OCTAVE_LOCAL_BUFFER( double ,rsdata,m.capacity());
OCTAVE_LOCAL_BUFFER( double ,isdata,m.capacity());
// Fill them with their respective value
  for (octave_idx_type ix = 0; ix < m.capacity(); ix++)
  {
      rsdata[ix]=real(m.data(ix));
      isdata[ix]=imag(m.data(ix));
//       printf("sending %d \n",sdata[ix]);   
      sridx[ix]= m.ridx(ix);
//        printf("sending %i \n",sridx[ix]);   
  }
  for (octave_idx_type ix = 0; ix < m.cols()+1; ix++)
  {
      scidx[ix]= m.cidx(ix);   
//        printf("sending %i \n",scidx[ix]);   

  }



  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm);
      if (info !=MPI_SUCCESS) return info;
// send the sintsparse vector named s
          info = MPI_Send(s, 1, sintsparse, rankrec(i), tanktag[1], comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector with row indexes
      info =  MPI_Send(sridx,1,rowindex,rankrec(i),tanktag[2],comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector with column indexes
      info =  MPI_Send(scidx,1,columnindex,rankrec(i),tanktag[3],comm);
      if (info !=MPI_SUCCESS) return info;
// send the vector of non zero elements
// real
      info =  MPI_Send(rsdata,1,numnnz,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
// img
      info =  MPI_Send(isdata,1,numnnz,rankrec(i),tanktag[5],comm);
      if (info !=MPI_SUCCESS) return info;

  }


return(info);
}


int send_complex_matrix(MPI_Comm comm, ComplexNDArray myCNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myCNDA.nelem();
  dim_vector dv = myCNDA.dims();
  OCTAVE_LOCAL_BUFFER(int,tanktag,6);
//   int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;
tanktag[5]= tanktag[4]+1;

  int nd = myCNDA.ndims ();
  int t_id = ov_complex_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguous derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

  NDArray rarray = real(myCNDA);
  NDArray imarray = imag(myCNDA);
  double *preal  = rarray.fortran_vec();
  double *pimag  = imarray.fortran_vec();

// two fortran_vec one for the real part and other one for the complex part
  OCTAVE_LOCAL_BUFFER(double,LBNDA,nitem);
  OCTAVE_LOCAL_BUFFER(double,CLBNDA,nitem);

  for (octave_idx_type i=0; i<nitem; i++)
  {
      LBNDA[i] = rarray(i) ;
      CLBNDA[i] = imarray(i) ;
  }

  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_DOUBLE, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
      info =  MPI_Send(CLBNDA,1,fortvec,rankrec(i),tanktag[5],comm);
      if (info !=MPI_SUCCESS) return info;

  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}



int send_float_complex_matrix(MPI_Comm comm, FloatComplexNDArray myCNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myCNDA.nelem();
  dim_vector dv = myCNDA.dims();
  OCTAVE_LOCAL_BUFFER(int,tanktag,6);
//   int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;
tanktag[5]= tanktag[4]+1;

  int nd = myCNDA.ndims ();
  int t_id = ov_float_complex_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

  FloatNDArray rarray = real(myCNDA);
  FloatNDArray imarray = imag(myCNDA);
  float *preal  = rarray.fortran_vec();
  float *pimag  = imarray.fortran_vec();

// two fortran_vec one for the real part and other one for the complex part
    OCTAVE_LOCAL_BUFFER(float,LBNDA,nitem);
  OCTAVE_LOCAL_BUFFER(float,CLBNDA,nitem);

  for (octave_idx_type i=0; i<nitem; i++)
  {
      LBNDA[i] = rarray(i) ;
      CLBNDA[i] = imarray(i) ;
  }

  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_FLOAT, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);/**/
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
      info =  MPI_Send(CLBNDA,1,fortvec,rankrec(i),tanktag[5],comm);
      if (info !=MPI_SUCCESS) return info;

  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}




int send_range(MPI_Comm comm, Range range,ColumnVector rankrec, int mytag){        /* put base,limit,incr,nelem */
/*-------------------------------*/        /* just 3 doubles + 1 int */
// octave_range (double base, double limit, double inc)
  OCTAVE_LOCAL_BUFFER(double,d,3);
  d[0]= range.base();
  d[1]= range.limit();
  d[2]= range.inc();
  int info;
    for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
  info = MPI_Send(d, 3, MPI_INT, rankrec(i), mytag, comm);
  }
   if (info !=MPI_SUCCESS) return info;
return(MPI_SUCCESS);
}

int send_matrix(MPI_Comm comm, NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();
  OCTAVE_LOCAL_BUFFER(int,tanktag,5);
//   int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= mytag+1;
tanktag[2]= mytag+2;
tanktag[3]= mytag+3;
tanktag[4]= mytag+4;


  int nd = myNDA.ndims ();
  int t_id = ov_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguous derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

    OCTAVE_LOCAL_BUFFER(double,LBNDA,nitem);
    double *p  = myNDA.fortran_vec();

  for (octave_idx_type i=0; i<nitem; i++)
  {
      LBNDA[i] = myNDA(i) ;
  }

  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_DOUBLE, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray/**/
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
return(info);
}

// Here we have float_matrix
int send_float_matrix(MPI_Comm comm, FloatNDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_float_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguous derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

    OCTAVE_LOCAL_BUFFER(float,LBNDA,nitem);
    float *p  = myNDA.fortran_vec();

  for (octave_idx_type i=0; i<nitem; i++)
  {
      LBNDA[i] = myNDA(i) ;
  }

  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_FLOAT, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}




int send_i8_mat(MPI_Comm comm, int8NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_int8_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_BYTE, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}





int send_i16_mat(MPI_Comm comm, int16NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_int16_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_SHORT, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}


int send_i32_mat(MPI_Comm comm, int32NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_int32_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_INT, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}

int send_i64_mat(MPI_Comm comm, int64NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_int64_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_LONG_LONG, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}
int send_ui8_mat(MPI_Comm comm, uint8NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_uint8_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_UNSIGNED_CHAR, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}

int send_ui16_mat(MPI_Comm comm, uint16NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_uint16_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_UNSIGNED_SHORT, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}
int send_ui32_mat(MPI_Comm comm, uint32NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_uint32_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_UNSIGNED, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}




int send_ui64_mat(MPI_Comm comm, uint64NDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_uint64_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
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
  MPI_Type_contiguous(nitem,MPI_UNSIGNED_LONG_LONG, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}




int send_ch_mat(MPI_Comm comm, charNDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();
 
OCTAVE_LOCAL_BUFFER(int,tanktag,5);
//   int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_char_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

    OCTAVE_LOCAL_BUFFER(char,LBNDA,nitem);

  for (octave_idx_type i=0; i<nitem; i++)
  {
      LBNDA[i] = myNDA(i) ;
  }

  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_CHAR, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//           printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}



int send_bl_mat(MPI_Comm comm, boolNDArray myNDA,ColumnVector rankrec, int mytag){       
  int info;
  int nitem = myNDA.nelem();
  dim_vector dv = myNDA.dims();

  int  tanktag[5];
tanktag[0] = mytag;
tanktag[1]= tanktag[0]+1;
tanktag[2]= tanktag[1]+1;
tanktag[3]= tanktag[2]+1;
tanktag[4]= tanktag[3]+1;


  int nd = myNDA.ndims ();
  int t_id = ov_matrix;
// Declare here the octave_local_buffers
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
 for (octave_idx_type i=0; i<nd; i++)
 {
  dimV[i] = dv(i) ;
 }

  // Now create the contiguos derived datatype
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

    OCTAVE_LOCAL_BUFFER(int,LBNDA,nitem);

  for (octave_idx_type i=0; i<nitem; i++)
  {
      LBNDA[i] = myNDA(i) ;
  }

  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_INT, &fortvec);
  MPI_Type_commit(&fortvec);

  for (octave_idx_type  i = 0; i< rankrec.nelem(); i++)
  {
//       t_id is the identifier of octave NDArray
//       printf("Sending block to %i \n",rankrec(i));   
          info = MPI_Send(&t_id, 1, MPI_INT, rankrec(i), tanktag[0], comm); 
//         printf("I have sent  %i \n",t_id);
      if (info !=MPI_SUCCESS) return info;
//       nitem is the total number of elements 
          info = MPI_Send(&nitem, 1, MPI_INT, rankrec(i), tanktag[1], comm);
//          printf("I have sent  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Send(&nd, 1, MPI_INT, rankrec(i), tanktag[2], comm);
//       printf("I have sent  %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//    vector of dimensions sending
          info = MPI_Send(dimV, 1, dimvec, rankrec(i), tanktag[3], comm);
      if (info !=MPI_SUCCESS) return info;
//      data matrix sending
      info =  MPI_Send(LBNDA,1,fortvec,rankrec(i),tanktag[4],comm);
      if (info !=MPI_SUCCESS) return info;
  }
//    printf("info for sending scalar matrix is = %i \n",info);
return(info);
}



int send_class(MPI_Comm comm, octave_value ov, ColumnVector rankrec,int mytag){    /* varname-strlength 1st, dims[ndim] */
/*----------------------------------*/    /* and then appropriate specific info */
  int t_id = ov.type_id();
//    printf("t_id THAT I WANT TO SEND=%i\n",t_id);


  switch (t_id) {
      case ov_cell:    	 	 	return(send_cell   (comm, ov.cell_value   (),rankrec,mytag));
      case ov_scalar:    	 	return(send_scalar (comm, ov.scalar_value (),rankrec,mytag));
      case ov_complex_scalar:    	return(send_complex_scalar(comm, ov.complex_value(),rankrec,mytag));
      case ov_matrix:    	 	return(send_matrix (comm, ov.array_value  (),rankrec,mytag));
      case ov_sparse_matrix:  	 	return(send_sp_mat (comm, ov.sparse_matrix_value (),rankrec,mytag));
      case ov_complex_matrix:    	return(send_complex_matrix(comm, ov.complex_array_value(),rankrec,mytag));
      case ov_sparse_complex_matrix:  	return(send_sp_cx_mat(comm, ov.sparse_complex_matrix_value (),rankrec,mytag));
      case ov_float_scalar:    		return(send_float_scalar (comm, ov.float_scalar_value (),rankrec,mytag));
      case ov_float_complex_scalar:     return(send_float_complex_scalar(comm, ov.float_complex_value(),rankrec,mytag));
      case ov_float_matrix:    		return(send_float_matrix (comm, ov.array_value  (),rankrec,mytag));
      case ov_float_complex_matrix:     return(send_float_complex_matrix(comm,ov.float_complex_array_value(),rankrec,mytag));

      case ov_range:    		return(send_range  (comm, ov.range_value  (),rankrec,mytag));
      case ov_bool:    			return(send_bool   (comm, ov.bool_value   (),rankrec,mytag));
      case ov_bool_matrix:    		return(send_bl_mat (comm, ov.bool_array_value(),rankrec,mytag));
      case ov_sparse_bool_matrix:  	return(send_sp_bl_mat (comm, ov.sparse_bool_matrix_value (),rankrec,mytag));
      case ov_char_matrix:    		return(send_ch_mat (comm, ov.char_array_value(),rankrec,mytag));
      case ov_string:    		return(send_string (comm, ov.string_value(),rankrec,mytag));
      case ov_sq_string:  		return(send_string (comm, ov.string_value(),rankrec,mytag));
      case ov_int8_scalar:    		return(send_i8     (comm, ov.int8_scalar_value(),rankrec,mytag));
      case ov_int16_scalar:    		return(send_i16    (comm, ov.int16_scalar_value(),rankrec,mytag));
      case ov_int32_scalar:    		return(send_i32    (comm, ov.int32_scalar_value (),rankrec,mytag));
      case ov_int64_scalar:    		return(send_i64    (comm, ov.int32_scalar_value (),rankrec,mytag));
      case ov_uint8_scalar:    		return(send_ui8     (comm, ov.uint8_scalar_value(),rankrec,mytag));
      case ov_uint16_scalar:    	return(send_ui16    (comm, ov.uint16_scalar_value(),rankrec,mytag));
      case ov_uint64_scalar:    	return(send_ui64    (comm, ov.uint32_scalar_value(),rankrec,mytag));
      case ov_int8_matrix:    		return(send_i8_mat (comm, ov.int8_array_value(),rankrec,mytag));
      case ov_int16_matrix:    		return(send_i16_mat(comm, ov.int16_array_value(),rankrec,mytag));
      case ov_int32_matrix:    		return(send_i32_mat(comm, ov.int32_array_value(),rankrec,mytag));
      case ov_int64_matrix:    		return(send_i32_mat(comm, ov.int64_array_value(),rankrec,mytag));
      case ov_uint8_matrix:    		return(send_ui8_mat (comm, ov.uint8_array_value(),rankrec,mytag));
      case ov_uint16_matrix:    	return(send_ui16_mat(comm, ov.uint16_array_value(),rankrec,mytag));
      case ov_uint32_matrix:    	return(send_ui32_mat(comm, ov.uint32_array_value(),rankrec,mytag));
      case ov_uint64_matrix:    	return(send_ui64_mat(comm, ov.int64_array_value(),rankrec,mytag));
      case ov_struct:    		return(send_struct (comm, ov.map_value    (),rankrec,mytag));

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





DEFUN_DLD(MPI_Send,args,nargout, "MPI_Send sends almost any Octave datatypes into contiguous memory using openmpi library even over an hetherogeneous cluster i.e 32 bits CPUs and 64 bits CPU \n")
{
     octave_value retval;

  int nargin = args.length ();
  if (nargin != 4 )
    {
      error ("expecting 4 input arguments");
      return retval;
    }

//   MPI_Comm comm = nargin == 4 ? get_mpi_comm (args(3)) : MPI_COMM_WORLD;
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
