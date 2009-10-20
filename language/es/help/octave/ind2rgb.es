md5="ff2542add01c947985ab69a16d4d0f65";rev="6346";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{rgb} =} ind2rgb (@var{x}, @var{map})
@deftypefnx {Archivo de funci@'on} {[@var{r}, @var{g}, @var{b}] =} ind2rgb (@var{x}, @var{map})
Convierte uma imagen indexada en su componentes rojo, verde y azul.
Si el mapa de colores no contiene suficientes colores, completa con 
el @'ultimo color del mapa. Si se omite @var{map}, se usa la mapa de 
colores actual para la conversi@'on.
@seealso{rgb2ind, image, imshow, ind2gray, gray2ind}
@end deftypefn
