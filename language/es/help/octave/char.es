md5="7e092244ae9403f6bc2f8826ddd7dc5d";rev="5869";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} char (@var{x})
@deftypefnx {Funci@'on incorporada} {} char (@var{cell_array})
@deftypefnx {Funci@'on incorporada} {} char (@var{s1}, @var{s2}, @dots{})
Crea una cadena a partir de una matriz num@'erica, arreglo o lista.

Si el argumento es una matriz num@'erica, cada elemento de la matriz 
es convertido al caracter ASCII correspondiente. Por ejemplo,

@example
@group
char ([97, 98, 99])
     @result{} "abc"
@end group
@end example

Si el argumento es un arreglo de cadenas, el resultado es una cadena
en donde cada elemento corresponde con un elemento del arreglo.

Para m@'ultiples argumentos, el resultado es un cadena en donde cada 
elemento corresponde con los argumentos.

El valor retornado se completa con espacios en blanco cuando sea necesrio para hacer que cada fila tenga la misma longitud.
@end deftypefn
