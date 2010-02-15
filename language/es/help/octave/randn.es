md5="9aae95eb86e9e6e0a6861fb01ba2eef6";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} randn (@var{x})
@deftypefnx {Funci@'on cargable} {} randn (@var{n}, @var{m})
@deftypefnx {Funci@'on cargable} {} randn ("state", @var{x})
@deftypefnx {Funci@'on cargable} {} randn ("seed", @var{x})
Regresa una matriz con distribuci@'on normal con elementos seudoaleatorios
de valor medio cero y varianza 1. Los argumentos son sus propiedades igual 
que los argumentos para @code@{rand}.

Por defecto ,@code{randn} utiliza Marsaglia y Tsang "Ziggurat technique"
para transformar de una distribuci@'on uniforme a una normal,(G. Marsaglia 
y W.W. Tsang, 'Ziggurat m@'etodo para generar variables aleatorias',
J. Statistical Software, vol 5, 2000,
@url{http://www.jstatsoft.org/v05/i08/})
@seealso{rand,rande,randg,randp}
@end deftypefn