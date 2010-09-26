-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{b}, @var{c}] =} spdiags (@var{a})
@deftypefnx {Archivo de funci@'on} {@var{b} =} spdiags (@var{a}, @var{c})
@deftypefnx {Archivo de funci@'on} {@var{b} =} spdiags (@var{v}, @var{c}, @var{a})
@deftypefnx {Archivo de funci@'on} {@var{b} =} spdiags (@var{v}, @var{c}, @var{m}, @var{n})
Una generalización de la función @code{spdiag}. Llamada con un argumento
de entrada única, las diagonales distintas de cero @var{c} de  @var{A}
son extraidas. Con dos argumentos para extraer las diagonales dadas 
por el vector @var{c}.

Las otras dos formas de @code{spdiags} modifica la matriz de entrada
mediante la sustitución de las diagonales. estas usan las columnas
de @var{v} para sustituir las columnas representadas por el vector 
@var{c}. Si la matriz dispersa @var{a} es define entonces las 
diagonales de esta matriz son reemplazados. De lo contrario una matriz
de @var{m} por @var{n} se crea con las diagonales dada por @var{v}.

Los valores negativos de @var{c} representantan las diagonales por
debajo de la diagonal principal, y los valores positivos de @var{c}
diagonales por encima de la diagonal principal.

Por ejemplo

@example
@group
spdiags (reshape (1:12, 4, 3), [-1 0 1], 5, 4)
@result{}    5 10  0  0
      1  6 11  0
      0  2  7 12
      0  0  3  8
      0  0  0  4
@end group
@end example

@end deftypefn
