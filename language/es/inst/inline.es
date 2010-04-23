md5="571097cb8f840d5d0fb311fd0b4253af";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} inline (@var{str})
@deftypefnx {Función incorporada} {} inline (@var{str}, @var{arg1}, ...)
@deftypefnx {Función incorporada} {} inline (@var{str}, @var{n})
Crear una función inline de la cadena de caracteres @var{str}.
Si se llama con un único argumento, los argumentos de la función
generada se extraen de la propia función. Los argumentos generados
de la función estarán en orden alfabético. Cabe se@~{n}alar que
la i, y j son ignoradas como argumentos debido a la ambig@"{u}edad 
entre su uso como una variable o su uso como incorporado constante.
Todos los argumentos seguidos de un paréntesis se consideran 
funciones.

Si los argumentos segundo y posteriores son cadenas de caracteres,
estos son nombres de los argumentos de la función.

Si el segundo argumento es un entero @var{n}, los argumentos son
@code{"x"}, @code{"P1"}, @dots{}, @code{"P@var{N}"}.
@seealso{argnames, formula, vectorize}
@end deftypefn 