md5="b6bfe923387dc23eec1125791a85a28d";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} zeros (@var{x})
@deftypefnx {Función incorporada} {} zeros (@var{n}, @var{m})
@deftypefnx {Función incorporada} {} zeros (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Función incorporada} {} zeros (@dots{}, @var{class})
Retorna una matriz o un arreglo de N dimensiones cuyos elementos son 
0.

Los argumentos son manejados de la misma forma que los argumentos de @code{eye}.

El argumento opcional @var{class} permite seleccionar el tipo de datos 
retornados por @code{zeros}, por ejemplo 

@example
val = zeros (n,m, "uint8")
@end example

@noindent
retorna una matriz de @var{n} por @var{m} de ceros de representados 
mediante enteros de 8 bits.
@end deftypefn
