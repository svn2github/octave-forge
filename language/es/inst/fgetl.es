md5="aa82ab708380de565b817968dd9108e8";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} fgetl (@var{fid}, @var{len})
Lee los caracteres de un archivo, deteni@'endose despu@'es de cada cambio 
de l@'inea, EOF, o @var{len} caracteres leidos. Los caracteres leidos, 
excluyendo los posibles cambios de l@'inea finales, se retornan como una 
cadena.

Si se omite @var{len}, @code{fgetl} lee hasta el siguiente caracter de 
cambio de l@'inea.

Si no hay m@'as caracteres para leer, @code{fgetl} retorna @minus{}1.
@seealso{fread, fscanf}
@end deftypefn
