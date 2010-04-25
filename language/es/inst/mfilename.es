md5="0106cfa5697ea25aa2bc8e352b5b19ee";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} mfilename ()
@deftypefnx {Función incorporada} {} mfilename (@code{"fullpath"})
@deftypefnx {Función incorporada} {} mfilename (@code{"fullpathext"})
Retorna el nombre del archivo que se está ejecutando actualmente. En 
el nivel superior, retorna una cadena vacia. Dado el argumento 
@code{"fullpath"}, incluye la parte del nombre del directorio del archivo, 
sin la extensión.

Dado el argumento @code{"fullpathext"}, incluye la parte del nombre del 
directorio del archivo y la extensión.
@end deftypefn
