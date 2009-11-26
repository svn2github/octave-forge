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
#include "octave_comm.h"
#include <ov-cell.h>    // avoid errmsg "cell -- incomplete datatype"
#include <oct-map.h>    // avoid errmsg "Oct.map -- invalid use undef type"

// tested on Octave 3.2.3
// Octave 3.2.X

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



/*----------------------------------*/        /* forward declaration */



int recv_class( MPI_Comm comm, octave_value &ov,  int source, int mytag);        /* along the datatype */
/*----------------------------------*/    /* to send any octave_value */


int recv_string( MPI_Comm comm, octave_value  &ov, int source, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a  string value */

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
  MPI_Type_contiguous(nitem,MPI_CHAR, &fortvec);
  MPI_Type_commit(&fortvec);


   info = MPI_Recv(mess, 1,fortvec, source, tanktag[2] , comm,&stat);
//   printf("Flag for string received  %i \n",info);
   std::string cpp_string;
   cpp_string = mess;
   ov = cpp_string;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

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
//         printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//               printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguous datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
   
   dv(i) = dimV[i] ;
//    printf("I am printing dimvector  %i \n",dimV[i]);
 }
    NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(double,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_DOUBLE, &fortvec);
  MPI_Type_commit(&fortvec);
//       printf("I am printing dimvector  %i \n",tanktag[4]);
          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//             printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);

}

int recv_float_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

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
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//     printf("I am printing dimvector  %i \n",dimV[i]);
   dv(i) = dimV[i] ;
 }
    FloatNDArray myNDA(dv);
    float *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(float,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_FLOAT, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);

}



int recv_complex_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

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
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    NDArray rmyNDA(dv);  // for the real part
    NDArray imyNDA(dv);  // for the img part

   ComplexNDArray   oa (dv);            /* Create->Delete on ret?!? */

     double *p = rmyNDA.fortran_vec();
     double *ip = imyNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(double,LBNDA,nitem);
   OCTAVE_LOCAL_BUFFER(double,CLBNDA,nitem);

//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_DOUBLE, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;

          info = MPI_Recv((CLBNDA), 1,fortvec, source, tanktag[5] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;


  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      rmyNDA(i)=LBNDA[i];
      imyNDA(i)=CLBNDA[i];
      oa(i) = Complex (rmyNDA (i), imyNDA (i));
  }
    ov = oa;

return(MPI_SUCCESS);
}


int recv_float_complex_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

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
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    FloatNDArray rmyNDA(dv);  // for the real part
    FloatNDArray imyNDA(dv);  // for the img part

   FloatComplexNDArray   oa (dv);            /* Create->Delete on ret?!? */

     float *p = rmyNDA.fortran_vec();
     float *ip = imyNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(float,LBNDA,nitem);
   OCTAVE_LOCAL_BUFFER(float,CLBNDA,nitem);

//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_DOUBLE, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;

          info = MPI_Recv((CLBNDA), 1,fortvec, source, tanktag[5] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;


  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      rmyNDA(i)=LBNDA[i];
      imyNDA(i)=CLBNDA[i];
      std::complex<float>  c  = real(rmyNDA(i))+imag(imyNDA(i));
      oa(i) = c;
  }
    ov = oa;

return(MPI_SUCCESS);
}






int recv_sp_mat(MPI_Comm comm, octave_value &ov,int source, int mytag){   
int info;   
/*     int nr = m.rows();
     int nc = m.cols (); 
     int nnzm = m.nzmax ();*/
// tag[0] ----> type of octave_value
// tag[1] ----> array of three elements 1) num of rows 2) number of columns 3) number of non zero elements
// tag[2] ---->  vector of rowindex
// tag[3] ---->  vector of columnindex
// tag[5] ---->  vector of number of non zero elements
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
if (info !=MPI_SUCCESS) return info;

// int appo1, appo2, appo3;
// appo1 = s[0];
// appo2 = s[1];
// appo3 = s[2];
//
// printf("appo 1 is %i \n",appo1);
// printf("appo 2 is %i \n",appo2);
// printf("appo 3 is %i \n",appo3);



SparseMatrix m(s[0],s[1],s[2]);

// Create a contiguous derived datatype for row index
OCTAVE_LOCAL_BUFFER(int,sridx,s[2]); 
OCTAVE_LOCAL_BUFFER(double,sdata,s[2]);
// Create a contiguous derived datatype for column index
OCTAVE_LOCAL_BUFFER(int,scidx,s[1]+1);  
MPI_Datatype rowindex;
MPI_Type_contiguous(s[2],MPI_INT, &rowindex);
MPI_Type_commit(&rowindex);
MPI_Datatype datavect;
MPI_Type_contiguous(s[2],MPI_DOUBLE, &datavect);
MPI_Type_commit(&datavect);
MPI_Datatype columnindex;
MPI_Type_contiguous(s[1]+1,MPI_INT, &columnindex);
MPI_Type_commit(&columnindex);

// Now receive the two vectors

// receive the vector with row indexes
      info =  MPI_Recv(sridx,1,rowindex,source,tanktag[2],comm,&stat);
//       printf("Hope everything is fine here with ridx %i =\n",info);
      if (info !=MPI_SUCCESS) return info;

// receive the vector with column indexes
      info =  MPI_Recv(scidx,1,columnindex,source,tanktag[3],comm, &stat);
//     printf("Hope everything is fine here with scidx %i =\n",info);
      if (info !=MPI_SUCCESS) return info;

      info =  MPI_Recv(sdata,1,datavect,source,tanktag[4],comm,&stat);
//       printf("Hope everything is fine here with data vect %i =\n",info);

// int appoc;
NDArray buf (dim_vector (m.capacity(), 1));
for (octave_idx_type i = 0; i < s[2]; i++)
{
    m.ridx(i) = sridx[i];
    m.data(i) = sdata[i];
    buf(i) = sdata[i];
//     appoc = m.ridx(i);
//     printf("apporow is %i \n",appoc);
//     printf("appodata is %d \n",sdata[i]);
}
for (octave_idx_type i = 0; i < s[1]+1; i++)
{
    m.cidx(i) = scidx[i];
//     appoc=m.cidx(i);
//     printf("appocol is %i \n",appoc);
}


ov = m;
return(info);


}


//here ! int matrixes
int recv_int8_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

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
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    int8NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_int8,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_BYTE, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);

}

int recv_int16_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;
  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    int16NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_int16,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_SHORT, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
   return(info);
}


int recv_int32_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    int32NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_int32,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_INT, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
   return(info);
}


int recv_int64_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    int64NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_int64,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_INT, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}



int recv_uint64_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    uint64NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_uint64,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_UNSIGNED_LONG_LONG, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}


int recv_uint8_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    uint8NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_uint8,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_UNSIGNED_CHAR, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}



int recv_uint16_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    uint16NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_uint16,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_UNSIGNED_SHORT, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_uint32_matrix(MPI_Comm comm, octave_value &ov,int source, int mytag){       

OCTAVE_LOCAL_BUFFER(int, tanktag, 5);
tanktag[0] = mytag;
tanktag[1] = mytag+1;
tanktag[2] = mytag+2;
tanktag[3] = mytag+3;
tanktag[3] = mytag+4;

  int info;
  int nitem,nd;
  MPI_Status stat;
  dim_vector dv;
 
//       nitem is the total number of elements 
          info = MPI_Recv((&nitem), 1,MPI_INT, source, tanktag[1] , comm,&stat);
//       printf("I have received number of elements  %i \n",nitem);
      if (info !=MPI_SUCCESS) return info;
//      ndims is number of dimensions
          info = MPI_Recv((&nd), 1,MPI_INT, source, tanktag[2] , comm,&stat);
//             printf("I have received number of dimensions %i \n",nd);
      if (info !=MPI_SUCCESS) return info;
//  Now create contiguos datatype for dim vector
  dv.resize(nd);
  OCTAVE_LOCAL_BUFFER(int,dimV,nd);
  MPI_Datatype dimvec;
  MPI_Type_contiguous(nd,MPI_INT, &dimvec);
  MPI_Type_commit(&dimvec);

          info = MPI_Recv((dimV), 1,dimvec, source, tanktag[3] , comm,&stat);
      if (info !=MPI_SUCCESS) return info;

// Now reverse the content of int vector into dim vector
 for (octave_idx_type i=0; i<nd; i++)
 {
//    printf("I am printing dimvector  %i \n",i);
   dv(i) = dimV[i] ;
 }
    uint32NDArray myNDA(dv);
//     double *p = myNDA.fortran_vec();
   OCTAVE_LOCAL_BUFFER(octave_uint32,LBNDA,nitem);
//    printf("BUFFER CREATED \n");
  // Now create the contiguous derived datatype
  MPI_Datatype fortvec;
  MPI_Type_contiguous(nitem,MPI_UNSIGNED, &fortvec);
  MPI_Type_commit(&fortvec);

          info = MPI_Recv((LBNDA), 1,fortvec, source, tanktag[4] , comm,&stat);
//           printf("info for receiving data is = %i \n",info);
      if (info !=MPI_SUCCESS) return info;
  for (octave_idx_type i=0; i<nitem; i++)
  {
//       *LBNDA = *p;
//       LBNDA++;
//       p++;
      myNDA(i)=LBNDA[i];
  }
    ov = myNDA;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}




int recv_complex_sp_mat(MPI_Comm comm, octave_value &ov,int source, int mytag){   
int info;   
/*     int nr = m.rows();
     int nc = m.cols (); 
     int nnzm = m.nzmax ();*/
// tag[0] ----> type of octave_value
// tag[1] ----> array of three elements 1) num of rows 2) number of columns 3) number of non zero elements
// tag[2] ---->  vector of rowindex
// tag[3] ---->  vector of columnindex
// tag[5] ---->  vector of number of non zero elements
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
if (info !=MPI_SUCCESS) return info;

// int appo1, appo2, appo3;
// appo1 = s[0];
// appo2 = s[1];
// appo3 = s[2];
//
// printf("appo 1 is %i \n",appo1);
// printf("appo 2 is %i \n",appo2);
// printf("appo 3 is %i \n",appo3);



SparseMatrix m(s[0],s[1],s[2]);

// Create a contiguous derived datatype for row index
OCTAVE_LOCAL_BUFFER(int,sridx,s[2]); 
OCTAVE_LOCAL_BUFFER(double,sdata,s[2]);
// Create a contiguous derived datatype for column index
OCTAVE_LOCAL_BUFFER(int,scidx,s[1]+1);  
MPI_Datatype rowindex;
MPI_Type_contiguous(s[2],MPI_INT, &rowindex);
MPI_Type_commit(&rowindex);
MPI_Datatype datavect;
MPI_Type_contiguous(s[2],MPI_DOUBLE, &datavect);
MPI_Type_commit(&datavect);
MPI_Datatype columnindex;
MPI_Type_contiguous(s[1]+1,MPI_INT, &columnindex);
MPI_Type_commit(&columnindex);

// Now receive the two vectors

// receive the vector with row indexes
      info =  MPI_Recv(sridx,1,rowindex,source,tanktag[2],comm,&stat);
//       printf("Hope everything is fine here with ridx %i =\n",info);
      if (info !=MPI_SUCCESS) return info;

// receive the vector with column indexes
      info =  MPI_Recv(scidx,1,columnindex,source,tanktag[3],comm, &stat);
//     printf("Hope everything is fine here with scidx %i =\n",info);
      if (info !=MPI_SUCCESS) return info;

      info =  MPI_Recv(sdata,1,datavect,source,tanktag[4],comm,&stat);
//       printf("Hope everything is fine here with data vect %i =\n",info);

// int appoc;
NDArray buf (dim_vector (m.capacity(), 1));
for (octave_idx_type i = 0; i < s[2]; i++)
{
    m.ridx(i) = sridx[i];
    m.data(i) = sdata[i];
    buf(i) = sdata[i];
//     appoc = m.ridx(i);
//     printf("apporow is %i \n",appoc);
//     printf("appodata is %d \n",sdata[i]);
}
for (octave_idx_type i = 0; i < s[1]+1; i++)
{
    m.cidx(i) = scidx[i];
//     appoc=m.cidx(i);
//     printf("appocol is %i \n",appoc);
}


ov = m;
   if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);


}









int recv_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  double d = ov.double_value();
  info = MPI_Recv((&d), 1,MPI_DOUBLE, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_int8_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_int8 d = ov.int8_scalar_value();
  info = MPI_Recv((&d), 1,MPI_BYTE, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_int16_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_int16 d = ov.int16_scalar_value();
  info = MPI_Recv((&d), 1,MPI_SHORT, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_int32_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_int32 d = ov.int32_scalar_value();
  info = MPI_Recv((&d), 1,MPI_INT, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_int64_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_int64 d = ov.int64_scalar_value();
  info = MPI_Recv((&d), 1,MPI_LONG_LONG, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_uint64_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_uint64 d = ov.uint64_scalar_value();
  info = MPI_Recv((&d), 1,MPI_UNSIGNED_LONG_LONG, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_uint32_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_uint32 d = ov.uint32_scalar_value();
  info = MPI_Recv((&d), 1,MPI_UNSIGNED, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_uint16_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_uint16 d = ov.uint16_scalar_value();
  info = MPI_Recv((&d), 1,MPI_UNSIGNED_SHORT, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_uint8_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  octave_uint8 d = ov.uint8_scalar_value();
  info = MPI_Recv((&d), 1,MPI_UNSIGNED_CHAR, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}









int recv_complex_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;

  OCTAVE_LOCAL_BUFFER(double,d,2);



  int info;
  MPI_Status stat;
  info = MPI_Recv((&d), 2,MPI_DOUBLE, source, tanktag[1] , comm,&stat);

  ov =Complex(d[0],d[1]);;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_complex_float_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Send it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;

  OCTAVE_LOCAL_BUFFER(float,d,2);



  int info;
  MPI_Status stat;
  info = MPI_Recv((&d), 2,MPI_FLOAT, source, tanktag[1] , comm,&stat);
  std::complex<float>  c = real(d[0])+imag(d[1]);
  ov =c;;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}






int recv_float_scalar( MPI_Comm comm, octave_value &ov, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a Float value */

OCTAVE_LOCAL_BUFFER(int,tanktag,2);
tanktag[0] = mytag;
tanktag[1] = mytag+1;


  int info;
  MPI_Status stat;
  float d = ov.float_value();
  info = MPI_Recv((&d), 1,MPI_FLOAT, source, tanktag[1] , comm,&stat);
  ov =d;
//   printf("info for scalar is = %i \n",info);
  if (info !=MPI_SUCCESS) return info;
   return(MPI_SUCCESS);
}

int recv_class(MPI_Comm comm, octave_value &ov, int source, int mytag ){    /* varname-strlength 1st, dims[ndim] */
/*----------------------------------*/    /* and then appropriate specific info */
  int t_id,n;
  MPI_Status status;
//   printf("1-> source =%i\n",source);
//   printf("2-> tag for id =%i\n",mytag);
  int info = MPI_Recv(&t_id,1, MPI_INT, source,mytag,comm,&status);

//    printf(" I have received t_id =%i\n",t_id);

  if (info !=MPI_SUCCESS) return info;

  switch (t_id) {

    case ov_scalar:    return(recv_scalar (comm, ov,source,mytag));
    case ov_int8_scalar:    return(recv_int8_scalar (comm, ov,source,mytag));
    case ov_int16_scalar:    return(recv_int16_scalar (comm, ov,source,mytag));
    case ov_int32_scalar:    return(recv_int32_scalar (comm, ov,source,mytag));
    case ov_int64_scalar:    return(recv_int64_scalar (comm, ov,source,mytag));
    case ov_uint8_scalar:    return(recv_uint8_scalar (comm, ov,source,mytag));
    case ov_uint16_scalar:    return(recv_uint16_scalar (comm, ov,source,mytag));
    case ov_uint32_scalar:    return(recv_uint32_scalar (comm, ov,source,mytag));
    case ov_uint64_scalar:    return(recv_uint64_scalar (comm, ov,source,mytag));
    case ov_float_scalar: return(recv_float_scalar(comm, ov,source,mytag));
    case ov_complex_scalar:    return(recv_complex_scalar (comm, ov,source,mytag));
    case ov_float_complex_scalar: return(recv_complex_float_scalar(comm, ov,source,mytag));

    case ov_string:    return(recv_string (comm, ov,source,mytag));
    case ov_matrix:    return(recv_matrix (comm, ov,source,mytag));
    case ov_complex_matrix:    return(recv_complex_matrix(comm, ov,source,mytag));
    case ov_int8_matrix:    return(recv_int8_matrix (comm, ov,source,mytag));
    case ov_int16_matrix:    return(recv_int16_matrix (comm, ov,source,mytag));
    case ov_int32_matrix:    return(recv_int32_matrix (comm, ov,source,mytag));
    case ov_int64_matrix:    return(recv_int64_matrix (comm, ov,source,mytag));


    case ov_uint8_matrix:    return(recv_uint8_matrix (comm, ov,source,mytag));
    case ov_uint16_matrix:    return(recv_uint16_matrix (comm, ov,source,mytag));
    case ov_uint32_matrix:    return(recv_uint32_matrix (comm, ov,source,mytag));
    case ov_uint64_matrix:    return(recv_uint64_matrix (comm, ov,source,mytag));

    case ov_float_matrix:    return(recv_float_matrix (comm, ov,source,mytag));
    case ov_float_complex_matrix:    return(recv_float_complex_matrix (comm, ov,source,mytag));
    case ov_sparse_matrix:    return(recv_sp_mat(comm, ov,source,mytag));
    case ov_sparse_complex_matrix:    return(recv_complex_sp_mat(comm, ov,source,mytag));
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





DEFUN_DLD(MPI_Recv,args,nargout, "MPI_Recv sends almost any Octave datatype into contiguous memory using openmpi library even over an hetherogeneous cluster i.e 32 bits CPUs and 64 bits CPU \n")
{
     octave_value_list retval;
  int nargin = args.length ();
  if (nargin != 3)
    {
      error ("expecting 3 input arguments");
      return retval;
    }

//   MPI_Comm comm = nargin == 4 ? get_mpi_comm (args(3)) : MPI_COMM_WORLD;
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


  if (!octave_comm_type_loaded)
    {
      octave_comm::register_type ();
      octave_comm_type_loaded = true;
      mlock ();
    }

	if (args(2).type_id()!=octave_comm::static_type_id()){
		
		error("Please enter a comunicator object!");
		return octave_value(-1);
	}

     const octave_base_value& rep = args(2).get_rep();
     const octave_comm& b = ((const octave_comm &)rep);
     MPI_Comm comm = b.comm;
	if (b.name == "MPI_COMM_WORLD")
	{
	 comm = MPI_COMM_WORLD;
	}
	else
	{
	 error("Other MPI Comunicator not yet implemented!");
	}


     octave_value result;
     int info = recv_class (comm, result,source, mytag );
     retval(1) = info;
     retval(0) = result;
     return retval;
   
}
