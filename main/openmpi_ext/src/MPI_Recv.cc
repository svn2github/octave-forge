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



int recv_class( MPI_Comm comm, octave_value &ov,  int source, int mytag);        /* along the datatype */
/*----------------------------------*/    /* to receive any octave_value */
 
int recv_cell(MPI_Comm comm,octave_value &ov, int source, int mytag);
int recv_struct( MPI_Comm comm, octave_value &ov, int source, int mytag);
int recv_string( MPI_Comm comm, octave_value &ov,int source, int mytag);
int recv_range(MPI_Comm comm, octave_value &ov,int source, int mytag);

template<class AnyElem>
int recv_vec(MPI_Comm comm, AnyElem &LBNDA, int nitem, MPI_Datatype TRCV ,int source, int mytag);

int recv_matrix(bool is_complex,MPI_Datatype TRcv, MPI_Comm comm, octave_value &ov,int source, int mytag);
int recv_sp_mat(bool is_complex,MPI_Datatype TRcv, MPI_Comm comm, octave_value &ov,int source, int mytag);

template <class Any>
int recv_scalar(MPI_Datatype TRcv, MPI_Comm comm, Any *d, int source, int mytag);
template <class Any>
int recv_scalar(MPI_Datatype TRcv, MPI_Comm comm, std::complex<Any> *d, int source, int mytag);




int recv_range(MPI_Comm comm, octave_value &ov,int source, int mytag){        /* put base,limit,incr,nelem */
/*-------------------------------*/        /* just 3 doubles + 1 int */
// octave_range (double base, double limit, double inc)
  MPI_Status stat;
  OCTAVE_LOCAL_BUFFER(int,tanktag,3);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  tanktag[2] = mytag+2;
  OCTAVE_LOCAL_BUFFER(double,d,2);

  // first receive
  int info = MPI_Recv(d, 3, MPI_DOUBLE,  source, tanktag[1] , comm,&stat);
  if (info !=MPI_SUCCESS) return info;
  int nelem=0;
  info = MPI_Recv(&nelem, 1, MPI_INT,  source, tanktag[2] , comm,&stat);
  if (info !=MPI_SUCCESS) return info;
//   b = d[0];
//   l = d[1];
//   i = d[2];
  Range r(d[0],d[2],nelem); 
  ov =r;
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
int recv_scalar(MPI_Datatype TRcv ,MPI_Comm comm, std::complex<Any> &d, int source, int mytag){        
  int info;
  MPI_Status stat;
  OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0] = mytag;
  tanktag[1] = mytag+1;
  OCTAVE_LOCAL_BUFFER(std::complex<Any>,Deco,2);
  Deco[0] = real(d);
  Deco[1] = imag(d);
		
  info = MPI_Recv((&Deco), 2,TRcv, source, tanktag[1] , comm,&stat);
  if (info !=MPI_SUCCESS) return info;

  return(info);
}

template <class Any>
int recv_scalar(MPI_Datatype TRcv , MPI_Comm comm, Any &d, int source, int mytag){        /* directly MPI_Recv it, */
/*-----------------------------*/        /* it's just a value */
OCTAVE_LOCAL_BUFFER(int,tanktag,2);
  tanktag[0]=mytag;
  tanktag[1]=mytag+1;
  int info;
  MPI_Status stat;
  info = MPI_Recv((&d), 1,TRcv, source, tanktag[1] , comm,&stat);
  if (info !=MPI_SUCCESS) return info;
   return(info);
}
int recv_string( MPI_Comm comm, octave_value &ov,int source, int mytag){        
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

int recv_matrix( bool is_complex,MPI_Datatype TRCV,const MPI_Comm comm, octave_value &ov,  int source, int mytag){       

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
		if (TRCV == MPI_DOUBLE and is_complex == false )
		      {
			NDArray myNDA(dv);
		      OCTAVE_LOCAL_BUFFER(double, LBNDA,nitem);
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			ov=myNDA;  
		      } 
		      
		else if (TRCV == MPI_DOUBLE and is_complex== true )
		      {
		      OCTAVE_LOCAL_BUFFER(double,LBNDA1,nitem);
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
		else if (TRCV == MPI_INT)
		      {
		      OCTAVE_LOCAL_BUFFER(bool,LBNDA,nitem);// tested on Octave 3.2.4
		      TRCV = MPI_INT;
		      info = recv_vec(comm, LBNDA,nitem ,TRCV ,source, tanktag[4]);
		      if (info !=MPI_SUCCESS) return info;
		      int32NDArray   myNDA(dv);
		      for (octave_idx_type i=0; i<nitem; i++)
			  {
			      myNDA(i)=LBNDA[i];
			  }
			  ov=myNDA;
		      }	  
		else if (TRCV == MPI_FLOAT)
		      {
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
		else if (TRCV == MPI_FLOAT and is_complex == true)
		     {
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
		else if  (TRCV == MPI_BYTE )   
		      {  	
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
		else if (TRCV == MPI_SHORT)  
		{  	
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
		
		else if (TRCV == MPI_LONG_LONG)  
		      {  	
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
		else if (TRCV == MPI_UNSIGNED_CHAR)  
		      { 	
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
		else if (TRCV == MPI_UNSIGNED_SHORT) 
		      {  	
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
		else if (TRCV == MPI_UNSIGNED) { 	
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
		else if (TRCV == MPI_UNSIGNED_LONG_LONG) 
		      { 	
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


int recv_sp_mat(bool is_complex,MPI_Datatype TRcv, MPI_Comm comm, octave_value &ov,int source, int mytag){   
int info;   
                
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

	      if (TRcv == MPI_INT)
		{  
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
		if (TRcv == MPI_DOUBLE  and is_complex==false)
		{  
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
		if (TRcv == MPI_DOUBLE  and is_complex==true)
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
  int t_id;
  MPI_Status status;
//       printf("1-> source =%i\n",source);
//       printf("2-> tag for id =%i\n",mytag);
     
  int info = MPI_Recv(&t_id,1, MPI_INT, source,mytag,comm,&status);
//   printf("3-> t_id =%i\n",t_id);
   
   static string_vector pattern = octave_value_typeinfo::installed_type_names ();
//          printf(" I have received t_id =%i\n",t_id);
  const std::string tstring = pattern(t_id); 
//   octave_stdout << "MPI_Recv has " << tstring  << " string argument.\n";
    if (tstring == "cell")   return(recv_cell ( comm,  ov,source,mytag));
    if (tstring == "struct") return(recv_struct(comm,  ov,source,mytag)); 
    if (tstring == "scalar")  {double 	 d=0; MPI_Datatype TRcv = MPI_DOUBLE ;info =(recv_scalar (TRcv,comm, d,source,mytag));ov=d;return(info);};
    if (tstring == "bool")    {bool 	 b; MPI_Datatype TRcv = MPI_INT;info = (recv_scalar (TRcv,comm, b,source,mytag));   ov=b ;return(info);};
    if (tstring == "int8 scalar")       {octave_int8   d; MPI_Datatype TRcv = MPI_BYTE;   info = (recv_scalar (TRcv,comm, d,source,mytag)); ov=d ;return(info);};
    if (tstring == "int16 scalar")        {octave_int16  d; MPI_Datatype TRcv = MPI_SHORT;  info = (recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);};
    if (tstring == "int32 scalar")        {octave_int32  d; MPI_Datatype TRcv = MPI_INT;  info = (recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);};
    if (tstring == "int64 scalar")        {octave_int64  d; MPI_Datatype TRcv = MPI_LONG_LONG;  info = (recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);};
    if (tstring == "uint8 scalar")        {octave_uint8  d; MPI_Datatype TRcv = MPI_UNSIGNED_CHAR;   info = (TRcv,recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);}; 
    if (tstring == "uint16 scalar")       {octave_uint16 d; MPI_Datatype TRcv = MPI_UNSIGNED_SHORT;   info = (recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);};
    if (tstring == "uint32 scalar")       {octave_uint32 d; MPI_Datatype TRcv = MPI_UNSIGNED;   info = (recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);};
    if (tstring == "uint64 scalar")       {octave_uint64 d; MPI_Datatype TRcv = MPI_UNSIGNED_LONG_LONG;   info = (recv_scalar (TRcv,comm, d,source,mytag));   ov=d ;return(info);};
    if (tstring == "float scalar")      {float 	 d; MPI_Datatype TRcv = MPI_FLOAT;   info =(recv_scalar (TRcv,comm, d,source,mytag)) ;  ov=d;return(info);};
    if (tstring == "complex scalar")     {std::complex<double>   d; MPI_Datatype TRcv = MPI_DOUBLE;   info =(recv_scalar (TRcv,comm, d,source,mytag)) ;  ov=d;return(info);};
    if (tstring == "float complex scalar") {std::complex<float> d; MPI_Datatype TRcv = MPI_FLOAT;   info =(recv_scalar (TRcv,comm, d,source,mytag)) ;  ov=d;return(info);};
    if (tstring == "string")  return(recv_string (comm, ov,source,mytag));
    if (tstring == "sq_string") return(recv_string (comm, ov,source,mytag));
    if (tstring == "range")		 {double b;double l;double i;int nelem;info =(recv_range (comm, ov,source,mytag));return(info);};
    if (tstring == "matrix")    		{ bool is_complex = false;MPI_Datatype TRcv = MPI_DOUBLE; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag); return(info);}	
    if (tstring == "complex matrix")		{ bool is_complex = true;MPI_Datatype TRcv = MPI_DOUBLE; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info); }
    if (tstring == "bool matrix")		{ bool is_complex = false;MPI_Datatype TRcv = MPI_INT; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}  
    if (tstring == "int8 matrix")  		{ bool is_complex = false;MPI_Datatype TRcv = MPI_BYTE; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}
    if (tstring == "int16 matrix") 		{ bool is_complex = false;MPI_Datatype TRcv = MPI_SHORT; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}
    if (tstring == "int32 matrix") 		{ bool is_complex = false;MPI_Datatype TRcv = MPI_INT; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}
    if (tstring == "int64 matrix") 		{ bool is_complex = false;MPI_Datatype TRcv = MPI_LONG_LONG; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}
    if (tstring == "uint8 matrix")		{ bool is_complex = false;MPI_Datatype TRcv = MPI_UNSIGNED_CHAR; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}
    if (tstring == "uint16 matrix")		{ bool is_complex = false;MPI_Datatype TRcv = MPI_UNSIGNED_SHORT; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag);return(info);}
    if (tstring == "uint32 matrix")		{ bool is_complex = false;MPI_Datatype TRcv = MPI_UNSIGNED; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag) ;return(info);}
    if (tstring == "uint64 matrix")		{ bool is_complex = false;MPI_Datatype TRcv = MPI_UNSIGNED_LONG_LONG; info = recv_matrix (is_complex,TRcv,comm,ov,source,mytag) ;return(info);}
    if (tstring == "float matrix")            	{ bool is_complex = false;MPI_Datatype TRcv = MPI_DOUBLE; info = recv_matrix (is_complex,TRcv,comm, ov,source,mytag) ;return(info);}
    if (tstring == "float complex matrix")    	{ bool is_complex = true;MPI_Datatype TRcv = MPI_FLOAT; info = recv_matrix(is_complex,TRcv,comm, ov,source,mytag) ;return(info);}
    if (tstring == "sparse matrix")		{ bool is_complex = false;MPI_Datatype TRcv = MPI_DOUBLE; info = recv_sp_mat(is_complex,TRcv,comm, ov,source,mytag) ;return(info);}
    if (tstring == "sparse complex matrix")   	{ bool is_complex = true;MPI_Datatype TRcv = MPI_DOUBLE; info = recv_sp_mat(is_complex,TRcv,comm, ov,source,mytag) ;return(info);}			
    if (tstring == "<unknown type>")    { printf("MPI_Recv: unknown class\n");
            return(MPI_ERR_UNKNOWN );

	    }

    else    {    printf("MPI_Recv: unsupported class %s\n",
                     ov.type_name().c_str());
             return(MPI_ERR_UNKNOWN );
 	    }
}



DEFUN_DLD(MPI_Recv, args, nargout,"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} [@var{VALUE} @var{INFO}]= MPI_Recv(@var{SOURCE},@var{TAG},@var{COMM})\n\
MPI_Recv receive any Octave datatype into contiguous memory using openmpi library even over an heterogeneous cluster i.e 32 bits CPUs and 64 bits CPU \n \n\
Returns @var{VALUE} that is an octave variable received\n\
and an integer @var{INFO} to indicate success or failure  \
 @example\n\
 @group\n\
@var{SOURCE} must be an integer indicating source processes \n\
@var{TAG} must be an integer to identify the message by openmpi \n\
@var{COMM} must be an octave communicator object created by MPI_Comm_Load function \n\
@end group\n\
@end example\n\
@seealso{MPI_Comm_Load,MPI_Init,MPI_Finalize,MPI_Send}\n\
@end deftypefn")
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
     retval(0) = result;
     return retval;
   
}
