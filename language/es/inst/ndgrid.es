md5="cb4c6afb1f2cfedbbb813b8b542e34b5";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{y1}, @var{y2}, @dots{},  @var{y}n] =} ndgrid (@var{x1}, @var{x2}, @dots{}, @var{x}n)
@deftypefnx {Archivo de funci@'on} {[@var{y1}, @var{y2}, @dots{},  @var{y}n] =} ndgrid (@var{x})
Dados n vectores @var{x1}, @dots{} @var{x}n, @code{ndgrid} regresa
n arreglos de dimensiones n. los elementos de la i-ava salida de
argumentos contienen los elementos del vector @var{x}i repetida durante
todas las  dimensiones diferentes de la dimension i-ava. Llamar ndgrid
con un solo argumento de entrada @var{x} es equivalente a llamar a
ndgrid con todos los n argumento de entrada iguales a @var{x}:
[@var{y1}, @var{y2}, @dots{},  @var{y}n] = ndgrid (@var{x}, @dots{}, @var{x})
@seealso{meshgrid}
@end deftypefn
