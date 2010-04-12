md5="571097cb8f840d5d0fb311fd0b4253af";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} inline (@var{str})
@deftypefnx {Funci@'on incorporada} {} inline (@var{str}, @var{arg1}, ...)
@deftypefnx {Funci@'on incorporada} {} inline (@var{str}, @var{n})
Crear una funci@'on inline de la cadena de caracteres @var{str}.
Si se llama con un @'unico argumento, los argumentos de la funci@'on
generada se extraen de la propia funci@'on. Los argumentos generados
de la funci@'on estar@'an en orden alfab@'etico. Cabe se@~{n}alar que
la i, y j son ignoradas como argumentos debido a la ambig@"{u}edad 
entre su uso como una variable o su uso como incorporado constante.
Todos los argumentos seguidos de un par@'entesis se consideran 
funciones.

Si los argumentos segundo y posteriores son cadenas de caracteres,
estos son nombres de los argumentos de la funci@'on.

Si el segundo argumento es un entero @var{n}, los argumentos son
@code{"x"}, @code{"P1"}, @dots{}, @code{"P@var{N}"}.
@seealso{argnames, formula, vectorize}
@end deftypefn 