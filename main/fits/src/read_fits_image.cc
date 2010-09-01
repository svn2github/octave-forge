/*
 *
 * To install, execute
 * $ mkoctfile -lcfitsio read_fits_image.cc
 * and copy read_fits_image.oct to a directory which is read by octave.
 *
 * This program is licensed under the terms of the GNU General Public License version 2.
 */
#include <iostream>
#include <sstream>
#include <octave/oct.h>

extern "C"
{
#include "fitsio.h"
}

static bool any_bad_argument( const octave_value_list& args );

DEFUN_DLD( read_fits_image, args, nargout,
"-*- texinfo -*-\n\
@deftypefn {Function File} {[@var{image},@var{header}]} = read_fits_image(@var{filename},@var{hdu})\n\
Read FITS file @var{filename} and return image data in @var{image}, and the image header in @var{header}.\n\
\n\
@var{filename} can be concatenated with filters provided by libcfitsio. See:\
<http://heasarc.gsfc.nasa.gov/docs/software/fitsio/c/c_user/node81.html>\
\n\n\
Examples:\n\
\n\
1. If the file contains a single image, read_fits_image( \"filename\" ) will store the data into a 2d double matrix.\n\
\n\
2. If the file contains a data cube (continous data, no exentions!), read_fits_image( \"filename\" ) will store the whole data cube into a 3d array.\n\
\n\
3. If the file contains a data cube, then read_fits_image( \"filename[*,*,2:5]\" ) will read the 2nd, 3rd, 4th, and 5th image, and store them into a 3d array.\n\
\n\
4. If the file contains multiple image extensions, then read_fits_image( \"filename[5]\" ) will read the 5th image. This is equivalent to read_fits_image( \"filename\", 5 ).\n\
\n\
NOTE: It's only possible to read one extension (HDU) at a time, i.e. multi-extension files need to be read in a loop.\n\
\n\
@seealso{save_fits_image, save_fits_image_multi_ext}\
Copyright (c) 2009-2010, Dirk Schmidt <fs@@dirk-schmidt.net>\
@end deftypefn")
{
  if ( any_bad_argument(args) )
    return octave_value_list();

  octave_value fitsimage; // the octave container for the image data to be read by this function
  std::string infile = args(0).string_value ();

  if ( args.length()==2 )
  {
    std::ostringstream stream;
    stream << infile << "[" << int(args(1).scalar_value()) << "]";
    infile = stream.str();
  }

  int status=0; // must be initialized with zero (I consider this to be a bug in libcfitsio).
                // status seems not to be set to zero after successful API calls

  // Open FITS file and position to first HDU containing an image
  fitsfile *fp;
  if ( fits_open_image( &fp, infile.c_str(), READONLY, &status) > 0 )
  {
      fprintf( stderr, "Could not open file %s.\n", infile.c_str() );
      fits_report_error( stderr, status );
      return fitsimage = -1;
  }

  // Gather informations about the image
  int bits_per_pixel, num_axis;
  long int sz_axes[3];
  memset( sz_axes, 0, sizeof(sz_axes) );
  if( fits_get_img_param( fp, 3, &bits_per_pixel, &num_axis, sz_axes, &status) > 0 )
  {
      fprintf( stderr, "Could not get image information.\n" );
      fits_report_error( stderr, status );
      return fitsimage = -1 ;
  }
  if( 2 == num_axis )
    sz_axes[2] = 1;

  //std::cerr << bits_per_pixel << " " << num_axis << " " << sz_axes[0] << " " << sz_axes[1] << " " << sz_axes[2] << std::endl;

  // Read image header
  int num_keys, key_pos;
  char card[FLEN_CARD];   /* standard string lengths defined in fitsioc.h */
  string_vector header;
  if( fits_get_hdrpos( fp, &num_keys, &key_pos, &status) > 0 ) // get number of keywords
  {
    fprintf( stderr, "Could not get number of header keywords\n" ) ;
    fits_report_error( stderr, status );
  }
  for( int i = 1; i <= num_keys; i++ ) // get the keywords
  {
    if ( fits_read_record( fp, i, card, &status ) )
    {
      fprintf( stderr, "Could not read header keyword\n" );
      fits_report_error( stderr, status );
    }
    else
    {
      header.append( std::string(card) );
    }
  }
  header.append( std::string("END\n") );  /* terminate listing with END */

  // Read image data and write it to an octave MArrayN type
  dim_vector dims;
  if( 2 == num_axis )
    dims = dim_vector( sz_axes[0], sz_axes[1] );
  else
    dims = dim_vector( sz_axes[0], sz_axes[1], sz_axes[2] );
  MArrayN<double> image_data( dims ); // a octace double-type array

  int type = TDOUBLE; // convert read data to double (done by libcfitsio)
  long fpixel[3] = {1,1,1}; // start at first pixel in all axes
  int  anynul;
  if( fits_read_pix( fp, type, fpixel, sz_axes[0]*sz_axes[1]*sz_axes[2], NULL, image_data.fortran_vec(),
                      &anynul, &status ) > 0 )
  {
       fprintf( stderr, "Could not read image.\n" );
       fits_report_error( stderr, status );
       return fitsimage = -1;
  }

  // Close FITS file
  if( fits_close_file(fp, &status) > 0 )
  {
      fprintf( stderr, "Could not close file %s.\n", infile.c_str() );
      fits_report_error( stderr, status );
  }

  octave_value_list retlist;
  retlist(0) =  image_data;
  retlist(1) =  header;

  return retlist;
}

static bool any_bad_argument( const octave_value_list& args )
{
  if ( args.length() < 1 || args.length() > 2 )
  {
    error( "read_fits_image: number of arguments - expecting read_fits_image( filename ) or read_fits_image( filename, extension )" );
    return true;
  }

  if( !args(0).is_string() )
  {
    error( "read_fits_image: filename (string) expected for first argument" );
    return true;
  }

  if( 2 == args.length() )
  {
    if( !args(1).is_scalar_type() )
    {
      error( "read_fits_image: second argument must be a positive scalar integer value" );
      return true;
    }
    double val = args(1).double_value();
    if( (D_NINT( val ) !=  val) || (val < 1) )
    {
      error( "read_fits_image: second argument must be a positive scalar integer value" );
      return true;
    }

  }

  return false;
}
