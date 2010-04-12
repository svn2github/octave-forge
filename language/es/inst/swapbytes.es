md5="4cb3c159f21d762a341b02a957b3bcdc";rev="6287";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} swapbytes (@var{x})
Intercambia el orden de los bytes en los valores, convirtiendo 
de little endian big endian y viceversa. Por ejemplo

@example
@group
swapbytes (uint16 (1:4))
@result{} [   256   512   768  1024]
@end group
@end example

@seealso{typecast, cast}
@end deftypefn
