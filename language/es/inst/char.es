md5="7e092244ae9403f6bc2f8826ddd7dc5d";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} char (@var{x})
@deftypefnx {Función incorporada} {} char (@var{cell_array})
@deftypefnx {Función incorporada} {} char (@var{s1}, @var{s2}, @dots{})
Crea una cadena a partir de una matriz numérica, arreglo o lista.

Si el argumento es una matriz numérica, cada elemento de la matriz 
es convertido al caracter ASCII correspondiente. Por ejemplo,

@example
@group
char ([97, 98, 99])
     @result{} "abc"
@end group
@end example

Si el argumento es un arreglo de cadenas, el resultado es una cadena
en donde cada elemento corresponde con un elemento del arreglo.

Para múltiples argumentos, el resultado es un cadena en donde cada 
elemento corresponde con los argumentos.

El valor retornado se completa con espacios en blanco cuando sea necesrio para hacer que cada fila tenga la misma longitud.
@end deftypefn
