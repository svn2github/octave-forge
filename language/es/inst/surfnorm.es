-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} surfnorm (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de funci@'on} {} surfnorm (@var{z})
@deftypefnx {Archivo de funci@'on} {[@var{nx}, @var{ny}, @var{nz}] =} surfnorm (@dots{})
@deftypefnx {Archivo de funci@'on} {} surfnorm (@var{h}, @dots{})
Determine los vectores normales a una superficie meshgridded. La
superficie enmalla se define por @var{x}, @var{y}, and @var{z}. Si
@var{x} y @var{y} no están definidos, entonces se asume que están dadas por

@example
[@var{x}, @var{y}] = meshgrid (1:size(@var{z}, 1), 
                     1:size(@var{z}, 2));
@end example

Si no se solicitan argumentos de retorno, un gráfico de superficie
con los vectores normales a la superficie se representa. De lo 
contrario los componetes de los vectores normales a los puntos de 
la malla cuadriculada se devuelven en @var{nx}, @var{ny}, y @var{nz}.

Los vectores normales son calculados tomando el producto vectorial de
las diagonales de cada uno de los cuadriláteros en la malla cuadriculada
para encontrar los vectores normales de los centros de estos 
cuadriláteros. Los cuatro mas cercanos vectores normales a los puntos
de la malla cuadriculada se promedian para obtener la normal a la 
superficie en los puntos de malla cuadriculada.

Un example de la implementación de @code{surfnorm} es

@example
surfnorm (peaks (25));
@end example
@seealso{surf, quiver3}
@end deftypefn
