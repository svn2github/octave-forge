##USAGE	s = mat2str( x, n, PLUS )
##	format real/complex numerical matrix x as string s
##	suitable for usage by 'eval' -function
##
##n	digits of precision     (default n=17)
##	n(1) : precision of  real parts format
##	n(2) : precision of  imag parts format
##PLUS	  1  : print '+' for pos. real parts (0 by def.)
##NOTE	* scalar n sets  n(2) = n(1) = n
##	* for real x any n(2) is ignored
##	* may fail for Octave V2.0.X and complex input
##EXA	mat2str( [ -1/3 + i/7; 1/3 - i/7 ], [4 2] )
##	|-       [-0.3333+0.14i;0.3333-0.14i]
##	mat2str( [ -1/3 +i/7; 1/3 -i/7 ], [4 2] )
##	|-       [-0.3333+0i,0+0.14i;0.3333+0i,-0-0.14i]
##	mat2str( [1-i -1+i],[],1 )   |-    [+1-1i,-1+1i]
##HINT	better use commas to seperate row-elements of x
##ASSOC	sprintf, int2str
##Copyright (C) 2002 Rolf Fabian <fabian@tu-cottbus.de> 020531
##	published under current GNU GENERAL PUBLIC LICENSE

function s=mat2str(x,n,PLUS)

if ( nargin<2||isempty(n) )
   n=17;		   # default precision
endif

if ( nargin<3||isempty(PLUS) )
   PLUS=0;		   # def. PLUS : DO NOT print leading '+'
			   #		 for positive real elements
endif

if ( nargin<1||nargin>3||isstr(x)||is_struct(x)||\
     isstr(n)||is_struct(n)||isstr(PLUS)||is_struct(PLUS) )
   usage ("mat2str( NUMERIC x, NUMERIC n, PLUS 0|1  )");
endif

if ( !(COMPLEX=is_complex(x)) )
   if ( !PLUS )
      FMT=sprintf("%%.%dg", n(1));
   else
      FMT=sprintf("%%+.%dg",n(1));
   endif
else
   if ( length(n)==1 )
      n=[n,n];
   endif
   if ( !PLUS )
      FMT=sprintf("%%.%dg%%+.%dgi", n(1),n(2));
   else
      FMT=sprintf("%%+.%dg%%+.%dgi",n(1),n(2));
   endif
endif

[nr,nc] = size(x);

if ( nr*nc==0 )         # empty .. only print brackets
   s = "[]";

elseif ( nr*nc==1 )	# scalar x .. don't print brackets
   if ( !COMPLEX )
      s = sprintf( FMT, x );
   else
      s = sprintf( FMT, real(x), imag(x) );
   endif

else			# non-scalar x .. print brackets
   FMT=[FMT,','];

   if ( !COMPLEX )

      s = sprintf( FMT, x.' );

   else

      x = x.';
      s = sprintf( FMT, [ real(x(:))'; imag(x(:))' ] );

   endif

   s=["[", s];
   s(length(s))= "]";
   IND= find(s == ",");
   s( IND(nc:nc:length(IND)) )= ";";

endif

endfunction
