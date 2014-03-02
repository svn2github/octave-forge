/*
  octcdf, a netcdf toolbox for octave 
  Copyright (C) 2005 Alexander Barth <barth.alexander@gmail.com>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; If not, see <http://www.gnu.org/licenses/>.
*/


#include "ov-netcdf.h"
#include "ov-ncfile.h"
#include "ov-ncvar.h"
#include "ov-ncatt.h"
#include "ov-ncdim.h"


#define CAST_DARRAY(arr) NDArray(arr)
#define CAST_CARRAY(arr) charNDArray(arr)

//
// Reverse dimension vector
//

dim_vector reverse(dim_vector dv) {
  dim_vector rdv = dv;

  for (int i = 0; i < dv.length(); i++) {
      rdv(i) = dv(dv.length() - i - 1);
    }

  return rdv;
}

static bool netcdf_type_loaded = false;

void load_netcdf_type () {
  octave_ncfile::register_type ();
  octave_ncvar::register_type ();
  octave_ncatt::register_type ();
  octave_ncdim::register_type ();

  netcdf_type_loaded = true;
}


void check_args_string(std::string funname, octave_value_list args) {

  for (int i=0; i< args.length(); i++) {
    if (!args(i).is_string()) {
      error("%s: all arguments should be string arguments",funname.c_str());
    }
  }  
}





DEFUN_DLD(netcdf, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{nc} = } netcdf(@var{filename},@var{mode}) \n\
@deftypefnx {Loadable Function} {@var{nc} = } netcdf(@var{filename},@var{mode},@var{format}) \n\
open or create a netcdf file given by @var{filename}. This function returns a netcdf file object. Possible values of @var{mode} are: \n\
@itemize \n\
@item \"r\", \"nowrite\": \
opens an existing file in read-only mode. \n\
@item \"w\", \"write\": \
opens an existing file in read-write mode. \n\
@item \"c\", \"clobber\": \
creates a new file and possibly overwrites existing data sets. \n\
@item \"nc\", \"noclobber\": \
creates a new file but an existing data sets in the netcdf file cannot be overwritten.\n\
@end itemize \n\
When a new file is created, the @var{format} can be specified: \n\
@itemize \n\
@item \"classic\": \
The default format subjected to the limitation described in http://www.unidata.ucar.edu/software/netcdf/docs/netcdf/NetCDF-Classic-Format-Limitations.html \n\
@item \"64bit-offset\": \
For large file and data sets. This format was introduced in NetCDF 3.6.0. \n\
@end itemize \n\
@end deftypefn\n\
@seealso{ncclose}\n")
{
  mlock ();
  string format;
  //

  if (! netcdf_type_loaded )
    load_netcdf_type ();

  if (args.length() != 2 && args.length() != 3 ) {
      print_usage ();
      return octave_value();
  }

  check_args_string("netcdf",args);

  if (args.length() == 3)
    format = args(2).string_value();
  else
    format = "classic";

  if (error_state)
    return octave_value();

  octave_ncfile *nc = new octave_ncfile(args(0).string_value(), args(1).string_value(),format);

  if (error_state) {
    delete nc;
    return octave_value();
  }
  else
    return octave_value(nc);
}


DEFUN_DLD(ncsync, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncsync(@var{nc}) \n\
All changes are written to the disk.\n\
@end deftypefn\n\
@seealso{ncclose}\n")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();
    ncfile.sync();
  } else {
    error("Error argument should be an ncfile");
  }

  return octave_value();
}

DEFUN_DLD(ncclose, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncclose(@var{nc}) \n\
closes the netcdf file @var{nc} and all changes are written to the disk.\n\
@end deftypefn\n\
@seealso{netcdf,ncsync}\n")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

# ifdef OV_NETCDF_VERBOSE
  octave_stdout << "close file "  << std::endl;
# endif

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();
    ncfile.close();
  } else {
    error("Error argument should be an ncfile");
  }

  return octave_value();
}

DEFUN_DLD(ncredef, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncredef(@var{nc}) \n\
Place an open NetCDF file in \"define\" mode, so that NetCDF entities can be added, renamed, modified, or deleted. With the octcdf toolbox, the \"define\" mode is entered automatically as needed.\n\
@end deftypefn\n\
@seealso{ncenddef}\n")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();
    ncfile.set_mode(DefineMode);
  } else {
    error("Error argument should be an ncfile");
  }

  return octave_value();
}



DEFUN_DLD(ncenddef, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncenddef(@var{nc}) \n\
Take an open NetCDF file out of \"define\" mode. The resulting state is called \"data\" mode. With the octcdf oolbox, the \"data\" mode is entered automatically as needed. \n\
@end deftypefn\n\
@seealso{ncredef}\n")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();
    ncfile.set_mode(DataMode);
  } else {
    error("Error argument should be an ncfile");
  }

  return octave_value();
}



DEFUN_DLD(ncvar, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncvar(@var{nc}) \n\
Creates a cell array of all variables in a NetCDF file. The content of a NetCDF variable can be accessed by using the \"(:)\" operator. \n\
@end deftypefn\n\
Example: \n\
@example \n\
nc = netcdf('test.nc','r'); \n\
nv = ncvar(nc)@{1@}; % gets the first variable in test.nc \n\
myvar = nv(:);     % copies the content of this NetCDF variable is myvar. \n\
@end example \n\
@seealso{ncatt,ncdim,ncname,ncdatatype}\n")
{
  mlock ();
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();

    Cell  vars = Cell (dim_vector(1,ncfile.get_nvars()));

    for (int i=0; i<ncfile.get_nvars(); i++) {
      octave_ncvar *v = new octave_ncvar(&ncfile,i);
      vars(i) = octave_value(v);
    }

    return octave_value(vars);
  } 
  else {
    error("Error argument should be an ncfile");
  }

  return octave_value();
}



DEFUN_DLD(ncatt, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncatt(@var{nc}) \n\
@deftypefnx {Loadable Function} ncatt(@var{nv}) \n\
Creates a cell array of all global attributes of NetCDF file @var{nc} or all attributes of variable @var{nv}. The content of a NetCDF attribute can be accessed by using the \"(:)\" operator. \n\
@end deftypefn\n\
Example: \n\
@example \n\
nc = netcdf('test.nc','r'); \n\
na = ncatt(nc)@{1@}; % gets the first global attribute in test.nc \n\
myvar = na(:);     % copies the content of this NetCDF attribute is myvar. \n\
@end example \n\
@seealso{ncvar,ncdim,ncname,ncdatatype}\n")
{
  mlock ();
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();

    Cell  vars = Cell (dim_vector(1,ncfile.get_natts()));

    for (int i=0; i<ncfile.get_natts(); i++) {
      octave_ncatt *v = new octave_ncatt(&ncfile,i);
      vars(i) = octave_value(v);
    }

    return octave_value(vars);
  } 
  else if (args(0).class_name() == "ncvar") {
    octave_ncvar& ncvar = (octave_ncvar&)args(0).get_rep();

    Cell  vars = Cell (dim_vector(1,ncvar.get_natts()));

    for (int i=0; i<ncvar.get_natts(); i++) {
      octave_ncatt *v = new octave_ncatt(&ncvar,i);
      vars(i) = octave_value(v);
    }

    return octave_value(vars);
  } 
  else {
    error("Error argument should be an ncfile or ncvar");
  }

  return octave_value();
}

DEFUN_DLD(ncdim, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncdim(@var{nc}) \n\
@deftypefnx {Loadable Function} ncdim(@var{nv}) \n\
Creates a cell array of all dimenstion in a NetCDF file. The length of the NetCDF length can be queried by using the \"(:)\" operator. \n\
@end deftypefn\n\
@seealso{ncvar}\n")
{
  mlock ();
  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();

    Cell  vars = Cell (dim_vector(1,ncfile.get_ndims()));

    for (int i=0; i<ncfile.get_ndims(); i++) {
      octave_ncdim *v = new octave_ncdim(&ncfile,i);
      vars(i) = octave_value(v);
    }

    return octave_value(vars);
  } 
  else if (args(0).class_name() == "ncvar") {
    octave_ncvar& ncvar = (octave_ncvar&)args(0).get_rep();

    Cell  vars = Cell (dim_vector(1,ncvar.ncndims() ));

    for (int i=0; i < ncvar.ncndims(); i++) {
      octave_ncdim *d = new octave_ncdim(ncvar.get_ncfile(),ncvar.get_dimid(i));
      vars(i) = octave_value(d);
    }
    
    return octave_value(vars);
    
  } 
  else {
    error("Error argument should be an ncfile or ncvar");
  }

  return octave_value();
}



DEFUN_DLD(ncname, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncname(@var{nc}) \n\
@deftypefnx {Loadable Function} ncname(@var{nv}) \n\
@deftypefnx {Loadable Function} ncname(@var{na}) \n\
@deftypefnx {Loadable Function} ncname(@var{nd}) \n\
@deftypefnx {Loadable Function} ncname(@var{nv},@var{new_name}) \n\
@deftypefnx {Loadable Function} ncname(@var{na},@var{new_name}) \n\
@deftypefnx {Loadable Function} ncname(@var{nd},@var{new_name}) \n\
Gets the name of the NetCDF file @var{nc}, variable @var{nv}, attributes \n\
@var{na} or dimension @var{nd}. If it is called with a second argument, the \n\
corresponding NetCDF object will be renamed. Only variables, attributes and \n\
dimensions can be renamed. \n\
@end deftypefn\n\
@seealso{ncvar,ncatt,ncdim}\n")
{

  if (args.length() < 1 || args.length() > 2) {
    print_usage ();
    return octave_value();
  }

  if (args(0).class_name() == "ncfile") {
    octave_ncfile& ncfile = (octave_ncfile&)args(0).get_rep();

    if (args.length() == 1) 
      return octave_value(ncfile.get_filename());
    else
      error("Error: cannot rename a ncfile");
  }

  else if (args(0).class_name() == "ncvar") {
    octave_ncvar& ncvar = (octave_ncvar&)args(0).get_rep();

    if (args.length() == 1) 
      return octave_value(ncvar.get_varname());
    else
      ncvar.rename(args(1).string_value());
  }

  else if (args(0).class_name() == "ncatt") {
    octave_ncatt& ncatt = (octave_ncatt&)args(0).get_rep();

    if (args.length() == 1) 
      return octave_value(ncatt.get_name());
    else
      ncatt.rename(args(1).string_value());
  }

  else if (args(0).class_name() == "ncdim") {
    octave_ncdim& ncdim = (octave_ncdim&)args(0).get_rep();

    if (args.length() == 1) 
      return octave_value(ncdim.get_name());
    else
      ncdim.rename(args(1).string_value());

  }
  else {
    error("Error argument should be an ncfile, ncvar, ncatt or ncdim");
  }

  return octave_value();
}


DEFUN_DLD(ncdatatype, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} ncdatatype(@var{nv}) \n\
@deftypefnx {Loadable Function} ncdatatype(@var{na}) \n\
Gets the datatype of the NetCDF variable @var{nv} or attributes @var{na}. \n\
@end deftypefn\n\
@seealso{ncvar,ncatt,ncdim}\n")
{
  nc_type type;

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() == "ncvar") {
    octave_ncvar& ncvar = (octave_ncvar&)args(0).get_rep();
    type = ncvar.get_nctype();
  }
  else if (args(0).class_name() == "ncatt") {
    octave_ncatt& ncatt = (octave_ncatt&)args(0).get_rep();
    type = ncatt.get_nctype();
  }
  else {
    error("Error argument should be an ncvar or ncatt");
    return octave_value();
  }

  return octave_value(nctype2ncname(type));
}



DEFUN_DLD(ncautonan, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} @var{status} = ncautonan(@var{nv}) \n\
@deftypefnx {Loadable Function} @var{nv} = ncautonan(@var{nv},@var{status}) \n\
If ncautonan is called with one argument, it returns the autonan status of the  \n\
NetCDF variable @var{nv}. With two arguments, it sets the autonan status to @var{status}.  \n\
If autonan status is 1, all NaNs in the octave variable to store are replaced by the corresponding  \n\
value of the _FillValue attribute. This feature is disabled if autonan is 0 (default). \n\
@end deftypefn\n\
@seealso{ncautoscale}\n")
{

  if (args.length() != 1 && args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() != "ncvar" ) {
      print_usage ();
      return octave_value();
    }

   octave_ncvar& ncvar = (octave_ncvar&)args(0).get_rep();

  if (args.length() == 1) {
    return octave_value(ncvar.autonan());
  }
  else {
     ncvar.autonan() = args(1).scalar_value() == 1;
    return octave_value(ncvar.clone());
  }
}

DEFUN_DLD(ncisrecord, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} @var{r} = ncisrecord(@var{nd}) \n\
Return 1 if the netcdf dimension is a record dimension, otherwise 0. \n\
@end deftypefn")
{

  if (args.length() != 1) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() != "ncdim" ) {
      print_usage ();
      return octave_value();
    }

   octave_ncdim& ncdim = (octave_ncdim&)args(0).get_rep();

   return octave_value(ncdim.is_record());
}



DEFUN_DLD(ncautoscale, args,, 
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} @var{status} = ncautoscale(@var{nv}) \n\
@deftypefnx {Loadable Function} @var{nv} = ncautoscale(@var{nv},@var{status}) \n\
If ncautoscale is called with one argument, it returns the autoscale status of the  \n\
NetCDF variable @var{nv}. With two arguments, it sets the autoscale status to @var{status}.  \n\
If autoscale status is 1, octave variable to store are scaled by the corresponding  \n\
value of the add_offset and scale_factor attribute:   \n\
@example \n\
octave_variable = scale_factor * netcdf_variable + add_offset  \n\
@end example \n\
This feature is disabled if autoscale is 0 (default). \n\
@end deftypefn\n\
@seealso{ncautoscale}\n")
{

  if (args.length() != 1 && args.length() != 2) {
      print_usage ();
      return octave_value();
    }

  if (args(0).class_name() != "ncvar" ) {
      print_usage ();
      return octave_value();
    }

   octave_ncvar& ncvar = (octave_ncvar&)args(0).get_rep();

  if (args.length() == 1) {
    return octave_value(ncvar.autoscale());
  }
  else {
     ncvar.autoscale() = args(1).scalar_value() == 1;
    return octave_value(ncvar.clone());
  }
}


//
// wrapper around the nc_get_att_* functions which provides directly an 
// octave_value of the appropriate type
// 

octave_value ov_nc_get_att(int ncid, int varid,const std::string name) {
  int status;
  octave_value retval;
  size_t lenp;
  nc_type xtypep;

  status =
    nc_inq_att(ncid, varid,name.c_str(), &xtypep, &lenp);

  if (status != NC_NOERR) {
    // attrinute doesn't exist -> return an empty matrix
    return octave_value(Matrix(0,0));
  }

  switch (xtypep)
    {
    case NC_CHAR:
      {
	char *var = new char[lenp + 1];
	status =
	  nc_get_att_text(ncid, varid,name.c_str(),
			  var);
        if (status  != NC_NOERR)                                      
	  error("Error while retrieving attribute %s: %s",            
	 	name.c_str(),nc_strerror(status));                    

	var[lenp] = 0; 
	retval = octave_value(var);
        delete[] var;
	break;
      }

      // cpp macro to avoid repetetive code

#define OV_NETCDF_ATT_CASE(netcdf_type,c_type,nc_get_att)		\
      case netcdf_type:							\
	{                                                               \
	  c_type *var = new c_type[lenp];                               \
	  status = nc_get_att(ncid,varid,name.c_str(),var);             \
									\
	  if (status  != NC_NOERR)                                      \
	    error("Error while retrieving attribute %s: %s",            \
		  name.c_str(),nc_strerror(status));                    \
									\
	  if (lenp == 1) {					        \
	    retval = octave_value(*var);                                \
	  } else {                                                      \
	    Array<double> arr =  Array<double>(dim_vector(1,lenp));	\
	    for (unsigned int i=0; i<lenp; i++) {                       \
	      arr.xelem(i) = (double)var[i];                            \
	    }                                                           \
	    retval = octave_value(arr);                                 \
	  }                                                             \
									\
	  delete[] var;                                                 \
	  break;                                                        \
	} 

        OV_NETCDF_ATT_CASE(NC_BYTE,signed char,nc_get_att_schar)
	OV_NETCDF_ATT_CASE(NC_SHORT,short,nc_get_att_short)
	OV_NETCDF_ATT_CASE(NC_INT,int,nc_get_att_int)
	OV_NETCDF_ATT_CASE(NC_FLOAT,float,nc_get_att_float)
	OV_NETCDF_ATT_CASE(NC_DOUBLE,double,nc_get_att_double)
	// for now int and long are the same in the netcdf library
#if NC_INT!=NC_LONG
	OV_NETCDF_ATT_CASE(NC_LONG,long,nc_get_att_long)
#endif

#undef OV_NETCDF_ATT_CASE

	default: 
      {
        error("unknown netcdf type: %d",xtypep);
      }
    }       


  return retval;

}
            

void ov_nc_put_att(int ncid, int varid,const std::string name,
   nc_type nctype,const octave_value rhs) {

  int status,length;

  //	    octave_stdout << "att2" << nctype << endl;

  switch (nctype)  {
    case NC_CHAR: {

      status =
	nc_put_att_text(ncid,varid, name.c_str(),
			rhs.string_value().length(),
			rhs.string_value().c_str());
      break;
      }

#define OV_NETCDF_ATT_PUT_ARR_CASE(netcdf_type,c_type,nc_put_att) \
    case netcdf_type: { \
	c_type *var = ov_ctype<c_type>(rhs,length);   \
	status = nc_put_att(ncid,varid, name.c_str(),nctype,(size_t)length,var); \
        delete[] var; \
	break; \
    } \

    OV_NETCDF_ATT_PUT_ARR_CASE(NC_BYTE,signed char,nc_put_att_schar)
    OV_NETCDF_ATT_PUT_ARR_CASE(NC_SHORT,short,nc_put_att_short)
    OV_NETCDF_ATT_PUT_ARR_CASE(NC_INT,int,nc_put_att_int)
    OV_NETCDF_ATT_PUT_ARR_CASE(NC_FLOAT,float,nc_put_att_float)
    OV_NETCDF_ATT_PUT_ARR_CASE(NC_DOUBLE,double,nc_put_att_double)
      // for now int and long are the same in the netcdf library
#if NC_INT!=NC_LONG
    OV_NETCDF_ATT_PUT_ARR_CASE(NC_LONG,long,nc_put_att_long)
#endif

    default: {
	status = NC_NOERR;
	error("Unknown type of variable: %d", nctype);        
    } 
  }

}



octave_value ov_nc_get_vars(int ncid, int varid,std::list<Range> ranges,nc_type nctype) {

  int ncndim = ranges.size();
  octave_value retval;
  long *start = new long[ncndim];
  long *count = new long[ncndim];
  long *stride = new long[ncndim];
  long sliced_numel = 1;
  Array<double> arr;
  dim_vector sliced_dim_vector;
  int status;
  // permutation vector for Fortran-storage to C-storage
  // not used if ncndim == 1
  Array<int> perm_vector(dim_vector(ncndim,1));

#  ifdef OV_NETCDF_VERBOSE
  octave_stdout << " ov_nc_get_vars" << std::endl;
#  endif


  // octave arrays have at least 2 dimensions
  // while NetCDF arrays can have only 1 dimensions

  //int ndim = max(ncndim,2);

  int i = 0;
  std::list<Range>::const_iterator it;

  for(it=ranges.begin(); it!=ranges.end(); ++it) { 
      start[i] =  (long int) (*it).min() - 1;
      count[i] = (*it).nelem();
      stride[i] = (long int) (*it).inc();
      sliced_numel *= count[i];
      perm_vector(i) = ncndim-i-1 + OCTAVE_PERMVEC_INDEX_ORIGIN;
      i=i+1;
    }

  if (ncndim <= 1) {
    // this sliced_dim_vector is to be reversed
    sliced_dim_vector.resize(2);
    sliced_dim_vector(0) = 1;
    sliced_dim_vector(1) = sliced_numel;
  }
  else {
    sliced_dim_vector.resize(ncndim);
    for (int i = 0; i < ncndim; i++)	
      sliced_dim_vector(i) = count[i];
  }


#define OV_NETCDF_GET_VAR_CASE(netcdf_type,c_type,nc_get_vars)		   \
  case netcdf_type:							   \
    {									   \
      c_type *var = new c_type[sliced_numel];				   \
      status =								   \
	nc_get_vars(ncid, varid, (const size_t *) start,		   \
		    (const size_t *) count,				   \
		    (const ptrdiff_t *) stride, var);			   \
									   \
      if (status != NC_NOERR)						   \
	error("Error while retrieving variable: %s", nc_strerror(status)); \
									   \
      arr = Array < double >(reverse(sliced_dim_vector));		   \
									   \
      for (int i = 0; i < sliced_numel; i++)				   \
	arr.xelem(i) = (double)var[i];					   \
									   \
      delete[] var;							   \
                                                                           \
      if (STORAGE_ORDER == FORTRAN_ORDER || ncndim <= 1)		   \
        retval = octave_value(CAST_DARRAY(arr));                           \
      else                                                                 \
        retval = octave_value(CAST_DARRAY(arr.permute(perm_vector)));	   \
      break;								   \
    }

  switch (nctype) {

      OV_NETCDF_GET_VAR_CASE(NC_BYTE,signed char,nc_get_vars_schar)
      OV_NETCDF_GET_VAR_CASE(NC_SHORT,short,nc_get_vars_short)
      OV_NETCDF_GET_VAR_CASE(NC_INT,int,nc_get_vars_int)
      OV_NETCDF_GET_VAR_CASE(NC_FLOAT,float,nc_get_vars_float)
      OV_NETCDF_GET_VAR_CASE(NC_DOUBLE,double,nc_get_vars_double)

      case NC_CHAR: {

	char *var = new char[sliced_numel];
	status =
	  nc_get_vars_text(ncid, varid, (const size_t *) start,
			   (const size_t *) count,
			   (const ptrdiff_t *) stride, var);

	if (status != NC_NOERR)
	  error("Error while retrieving variable: %s", nc_strerror(status));

	//	charNDArray arr = charNDArray(reverse(sliced_dim_vector));
	Array<char> arr = Array<char>(reverse(sliced_dim_vector));

	for (int i = 0; i < sliced_numel; i++)
	  arr.xelem(i) = (char)var[i];

	delete[] var;

        if (STORAGE_ORDER == FORTRAN_ORDER || ncndim == 1)                                  
          retval = octave_value(CAST_CARRAY(arr));                                        
        else                                                                 
          retval = octave_value(CAST_CARRAY(arr.permute(perm_vector)));	  	   

	break;
      }

    default:  {
	error("Unknown type of variable: %d", nctype);
        
      } 
    }


  delete[] start;
  delete[] count;
  delete[] stride;


  return retval;
}


void ov_nc_put_vars(int ncid, int varid,std::list<Range> ranges,nc_type nctype,octave_value rhs) {

  int ncndim = ranges.size();
  octave_value retval;
  long *start = new long[ncndim];
  long *count = new long[ncndim];
  long *stride = new long[ncndim];
  long sliced_numel = 1;
  Array<double> arr;
  int status;
  // permutation vector for Fortran-storage to C-storage
  // not used if ncndim == 1
  Array<int> perm_vector(dim_vector(ncndim,1));


#  ifdef OV_NETCDF_VERBOSE
  octave_stdout << " ov_nc_put_vars" << std::endl;
#  endif

  int i = 0;
  std::list<Range>::const_iterator it;

  for(it=ranges.begin(); it!=ranges.end(); ++it) { 
      start[i] =  (long int) (*it).min() - 1;
      count[i] = (*it).nelem();
      stride[i] = (long int) (*it).inc();
      sliced_numel *= count[i];
      perm_vector(i) = ncndim-i-1 + OCTAVE_PERMVEC_INDEX_ORIGIN;
      i=i+1;
    }

#  ifdef OV_NETCDF_VERBOSE
  octave_stdout << "type " <<  rhs.type_name() << NC_INT << std::endl;
  octave_stdout << "class " <<  rhs.class_name() << std::endl;
  octave_stdout << "id " <<  rhs.type_id() << std::endl;
#  endif

  // check number of elements

  if (rhs.numel() !=  sliced_numel && rhs.numel() != 1) 
    error("octcdf: unexpected number of elements, found %d, expected 1 or %d ",rhs.numel(),sliced_numel);

  switch (nctype)
    {
    case NC_CHAR:
      {

	char *var = new  char[sliced_numel];

	if (rhs.numel() == 1) {
	  for (int i = 0; i < sliced_numel; i++) {
	      var[i] =  (char)rhs.string_value()[0];
	    }
	} 
	else {
	  Array<char> arr =  rhs.char_array_value();
									
          if (STORAGE_ORDER == C_ORDER && ncndim > 1 )				
	      arr = arr.permute(perm_vector);				

	  for (int i = 0; i < sliced_numel; i++) {
	      var[i] =  (char)arr.xelem(i);
	    }
	}

	status =
	  nc_put_vars_text(ncid, varid, (const size_t *) start,
			   (const size_t *) count,
			   (const ptrdiff_t *) stride, var);
	delete[] var;

	break;
      }


#define OV_NETCDF_PUT_VAR_CASE(netcdf_type,c_type,nc_put_vars)		\
      case netcdf_type:							\
	{								\
	  if (rhs.is_string())						\
	    error("octcdf: unexpected type: %s",rhs.type_name().c_str());\
									\
	  c_type *var = new  c_type[sliced_numel];			\
									\
	  if (rhs.is_scalar_type()) {					\
	    for (int i = 0; i < sliced_numel; i++)  {	      	        \
		var[i] =  (c_type)rhs.scalar_value();			\
	      }								\
	  }								\
	  else {							\
	    Array<double> arr = rhs.array_value();                      \
									\
	    if (STORAGE_ORDER == C_ORDER && ncndim > 1)	{	       	\
	      arr = arr.permute(perm_vector);				\
	    }								\
									\
	    for (int i = 0; i < sliced_numel; i++) {			\
		var[i] =  (c_type)arr.xelem(i);				\
	      }								\
	  }								\
									\
	  /* status will checked at end of switch */			\
									\
	  status =							\
	    nc_put_vars(ncid, varid, (const size_t *) start,		\
			(const size_t *)count,				\
			(const ptrdiff_t *)stride, var);		\
	  delete[] var;							\
									\
	  break;							\
	}                                                           

      OV_NETCDF_PUT_VAR_CASE(NC_BYTE,signed char,nc_put_vars_schar) 
      OV_NETCDF_PUT_VAR_CASE(NC_SHORT,short,nc_put_vars_short) 
      OV_NETCDF_PUT_VAR_CASE(NC_INT,int,nc_put_vars_int) 
      OV_NETCDF_PUT_VAR_CASE(NC_FLOAT,float,nc_put_vars_float) 
      OV_NETCDF_PUT_VAR_CASE(NC_DOUBLE,double,nc_put_vars_double) 
      // for now int and long are the same in the netcdf library
#if NC_INT!=NC_LONG
      OV_NETCDF_PUT_VAR_CASE(NC_LONG,long,nc_put_vars_long) 
#endif

#undef OV_NETCDF_PUT_VAR_CASE

      default: {
	status = NC_NOERR;
	error("Unknown type of variable: %d", nctype);        
      } 
    }


  if (status != NC_NOERR) {
      error("Error while stroring variable: %s", nc_strerror(status));
  }


  delete[] start;
  delete[] count;
  delete[] stride;

}


void ov_nc_def_var(int ncid,std::string name,nc_type nctype, std::list<std::string> dimnames) {
  int status;
  int ndims=0;
  int varid;

  int dimids[NC_MAX_VAR_DIMS];

  if (STORAGE_ORDER == FORTRAN_ORDER)
    dimnames.reverse();

  std::list<std::string>::const_iterator it;
  for(it=dimnames.begin(); it!=dimnames.end(); ++it) {
    status = nc_inq_dimid (ncid,(*it).c_str(), &dimids[ndims]);

    if (status != NC_NOERR)
      error("Error while querying dimension %s: %s",
	    (*it).c_str(), nc_strerror(status));

#   ifdef OV_NETCDF_VERBOSE
    octave_stdout << "query dimname " << *it << " id " <<  dimids[ndims] << std::endl; 
#   endif
    ndims=ndims+1;
  } 

  status = nc_def_var(ncid,name.c_str(),nctype,
		      ndims,dimids,&varid);

  if (status == NC_ENAMEINUSE) {
    octave_stdout << "variable " << name.c_str() << " already exist" << std::endl;
  }
  else if (status != NC_NOERR) {
    error("Error while defining variable %s: %s",
	  name.c_str(), nc_strerror(status));
  }

}









nc_type ncname2nctype(std::string name) {

  if (name == "byte")
    return NC_BYTE;
  else if (name == "char")
    return NC_CHAR;
  else if (name == "short")
    return NC_SHORT;
  else if (name == "int")
    return NC_INT;
  else if (name == "long")
    return NC_LONG;
  else if (name == "float")
    return NC_FLOAT;
  else if (name == "double")
    return NC_DOUBLE;
  else {
    error("Unknown type: %s",name.c_str());
    return NC_NAT ;
  }
}

std::string nctype2ncname(nc_type type) {

  switch (type) {
    case NC_BYTE: {
      return "byte";
      break;
    }
    case NC_CHAR: {
      return "char";
      break;
    }
    case NC_SHORT: {
      return "short";
      break;
    }
    case NC_INT: {
      return "int";
      break;
    }
#   if NC_INT!=NC_LONG
    case NC_LONG: {
      return "long";
      break;
    }
#   endif
    case NC_FLOAT: {
      return "float";
      break;
    }
    case NC_DOUBLE: {
      return "double";
      break;
    }
    default: {
      return "unknown type";
      break;
    }
  }
}



// guess netcdf type from octave type

nc_type ovtype2nctype(const octave_value& val) {

  if (val.is_string()) 
    return NC_CHAR;
#ifdef HAVE_OCTAVE_INT
  if (val.type_id() == octave_int8_scalar::static_type_id() ||
      val.type_id() == octave_int8_matrix::static_type_id())
    return NC_BYTE;
  if (val.type_id() == octave_int16_scalar::static_type_id() ||
      val.type_id() == octave_int16_matrix::static_type_id())
    return NC_SHORT;
  if (val.type_id() == octave_int32_scalar::static_type_id() ||
      val.type_id() == octave_int32_matrix::static_type_id())
    return NC_INT;
  if (val.type_id() == octave_int64_scalar::static_type_id() ||
      val.type_id() == octave_int64_matrix::static_type_id())
    return NC_LONG;
#endif
  else
    return NC_DOUBLE;
}

template <class ctype> ctype* ov_ctype(octave_value val,int& n) {
  ctype* var;
  n = val.numel();
  var = new ctype[n];

  if (n == 1) 
    var[0] =  (ctype)val.scalar_value();
  else {
    for (int i = 0; i < n; i++) {			
      var[i] =  (ctype)val.array_value().xelem(i);				
    }								
  }

  return var;
}


