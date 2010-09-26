-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{x} = } gradient (@var{M})
@deftypefnx {Archivo de funci@'on} {[@var{x}, @var{y}, @dots{}] = } gradient (@var{M})
@deftypefnx {Archivo de funci@'on} {[@dots{}] = } gradient (@var{M}, @var{s})
@deftypefnx {Archivo de funci@'on} {[@dots{}] = } gradient (@var{M}, @var{dx}, @var{dy}, @dots{})

Calcula el gradiente. @code{@var{x} = gradiente (@var{M})} 
calcula el gradiente unidimensional si @var{M}es un vector. Si 
@var{M} es una matriz el gradiente se calcula para cada fila.

@code{[@var{x}, @var{y}] = gradient (@var{M})} calcula el gradiente
de una sola dimensi�n para cada direcci�n si @var{M} es una matriz.
Otros argumentos adicionales de retorno puede ser usados para matrices 
multidimensionales.

Espacio entre los valores entre dos puntos pueden ser proporcionados por
los par�metros @var{dx}, @var{dy} o @var{h}. Si @var{h} se suministra se 
supone que el espacio en todas direcciones. De lo contrario, los valores
por separado de la separaci�n puede ser suministrado por @var{dx}, etc
variables. Un valor escalar especifica un espacio equidistante, mientras
que un valor vector puede ser usado para especificar el espacio variable.
La longitud debe coincidir con su dimensi�n respectiva de @var{M}.

En los puntos de frontera a una extrapolaci�n lineal se aplica. los puntos 
Interiores se calculan con la primera aproximaci�n del gradiente num�rico

@example
y'(i) = 1/(x(i+1)-x(i-1)) *(y(i-1)-y(i+1)).
@end example

@end deftypefn
