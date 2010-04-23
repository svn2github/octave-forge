md5="aa82ab708380de565b817968dd9108e8";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} fgetl (@var{fid}, @var{len})
Lee los caracteres de un archivo, deteniéndose después de cada cambio 
de línea, EOF, o @var{len} caracteres leidos. Los caracteres leidos, 
excluyendo los posibles cambios de línea finales, se retornan como una 
cadena.

Si se omite @var{len}, @code{fgetl} lee hasta el siguiente caracter de 
cambio de línea.

Si no hay más caracteres para leer, @code{fgetl} retorna @minus{}1.
@seealso{fread, fscanf}
@end deftypefn
