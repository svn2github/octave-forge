## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
## This code was adapted from, Paul Kienzle <pkienzle@users.sf.net>
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{rval}= {} base64decode(@var{code})
## @deftypefnx {Function File} @var{rval}= {} base64decode(@var{code},@var{as_string})
## convert a base64 @var{code}  (a string of printable characters according to RFC 2045) 
## into the original ASCII data set of range 0-255. If option @var{as_string} is 
## passed, the return value is converted into a string.
##
## @example
## @group
##           ##base64decode(base64encode('Hakuna Matata'),true)
##           base64decode('SGFrdW5hIE1hdGF0YQ==',true)
##           ##returns 'Hakuna Matata'
## @end group
## @end example
## @end deftypefn
## @seealso {base64encode}
##

##
## Y = base64decode(X)
##
## Convert X into string of printable characters according to RFC 2045.
## The input may be a string or a matrix of integers in the range 0..255.
##
## See: http://www.ietf.org/rfc/rfc2045.txt
##
function z = base64decode(X,as_string)
  if (nargin < 1 )
    usage("Y = base64decode(X); X need to be a 4-row N-col matrix");
  elseif nargin == 1
    as_string=false;
  endif

  if ( any(X(:) < 0) || any(X(:) > 255))
    error("base64decode is expecting integers in the range 0 .. 255");
  endif

  ##
  ## decompose strings into the 4xN matrices 
  ## formatting issues.
  ##
  if( rows(X) == 1 )
	Y=[];
	L=length(X);
	for z=4:4:L
		Y=[Y X(z-3:z)']; #keep adding columns
	end
	if min(size(Y))==1
		Y=reshape(Y,[L, 1]);
	else
	 	Y=reshape(Y,[4,L/4]);
	end
	X=Y;
	Y=[];
  end

  X = toascii(X);
  Xa= X;

  ##
  ## Work backwards. Starting at step in table,
  ## lookup the index of the element in the table.
  ##

  ## 6-bit encoding table, plus 1 for padding
  ## 26*2 + 10 + 2 + 1  = 64 + 1, '=' is EOF stop mark.
  table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

  S=size(X);
  SRows=S(1);
  SCols=S(2);
  Y=zeros(S);

  ## decode the incoming matrix & 
  ## write the values into Xa matrix.
  ##
  for idx_r = 1:SRows
	for idx_c=1:SCols
		v=Xa(idx_r,idx_c);
		w=-1;
		if (v >= 'A' && v <= 'Z')
			w=v-'A';
		elseif (v >= 'a' && v<='z')
			w=v-'a'+26;
		elseif (v >= '0' && v<= '9')
			w=v-'0'+52;
		elseif (v == '+')
                        w=62;
                elseif (v == '/')
                        w=63;
                elseif (v == '=')
                        w=0;%ignore me
		end
		Xa(idx_r,idx_c)=w;
	end
  end

  Y=Xa;
  Y1=Y(1,:);
  if (SRows > 1) 
     Y2=Y(2,:);
  else 
     Y2=zeros(1,SCols);
  end;

  if (SRows > 2)
     Y3=Y(3,:);
  else 
     Y3=zeros(1,SCols);
  end;

  if (SRows > 3) 
     Y4=Y(4,:);
  else 
     Y4=zeros(1,SCols);
  end;

  ## +1 not required due to ASCII subtraction
  ## actual decoding work
  b1 = Y1*4 + fix(Y2/16);
  b2 = mod(Y2,16)*16+fix(Y3/4);
  b3 = mod(Y3,4)*64 + Y4;

  ZEROS=sum(sum(Y==0));
  L=length(b1)*3;
  z=zeros(1,L);
  z(1:3:end)=b1;
  if (SRows > 1)
     z(2:3:end)=b2;
  else
     z(2:3:end)=[];
  end;

  if (SRows > 2)
     z(3:3:end)=b3;
  else
     z(3:3:end)=[];
  end

  ##
  ## FIXME
  ## is this expected behaviour?
  ##
  if ( as_string )
    L=length(z);
    while ( ( L > 0) && ( z(L)==0 ) )
      L=L-1;
    end
    z=char(z(1:L));
  end

  return

endfunction
%!
%!assert(base64decode(base64encode('Hakuna Matata'),true),'Hakuna Matata')
%!assert(base64decode(base64encode([1:255])),[1:255])
%!assert(base64decode(base64encode('taken'),true),'taken')
%!assert(base64decode(base64encode('sax'),true),'sax')
%!assert(base64decode(base64encode('H'),true),'H')
%!assert(base64decode(base64encode('Ta'),true),'Ta')
%!
