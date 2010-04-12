md5="1a77133f3b1f4fc20425eaca53053808";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} fgets (@var{fid}, @var{len})
Lee los caracteres de un archivo, deteni@'endose desp@'es de una linea 
nueva, o EOF, o @var{len} caracteres han sido leidos. Los caracteres 
a leer, incluyendo la posible nueva l@'inea al final, se retornan como 
una cadena. 

Si se omite @var{len}, @code{fgets} lee hasta que encuentra un caracter de 
l@'inea nueva.

Si no hay mas caracteres para leer, @code{fgets} retorna @minus{}1.
@seealso{fread, fscanf}
@end deftypefn
