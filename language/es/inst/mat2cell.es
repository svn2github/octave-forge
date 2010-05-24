md5="384b37ff5c6200f7fafb502ffe2c2761";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{b} =} mat2cell (@var{a}, @var{m}, @var{n})
@deftypefnx {Función cargable} {@var{b} =} mat2cell (@var{a}, @var{d1}, @var{d2}, @dots{})
@deftypefnx {Función cargable} {@var{b} =} mat2cell (@var{a}, @var{r})
Convierte la matriz @var{a} en un arreglo de celdas si @var{a} es 2-D,
entonces se requiere que el tamaño de @code{sum (@var{m}) == size (@var{a}, 1)} y 
@code{sum (@var{n}) == size (@var{a}, 2)}. Del mismo modo, si @var{a} es 
multi-dimensional y el número de argumentos dimensionales es igual a las 
dimensiones de @var{a}, entonces se requiere que @code{sum (@var{di})
== size (@var{a}, i)}.

Teniendo en cuenta un único argumento de dimensiones @var{r}, los 
otros argumentos de dimensiones se asumen igual a @code{size (@var{a},@var{i})}.

un ejemplo de el uso de mat2cell es 

@example
@group
mat2cell (reshape(1:16,4,4),[3,1],[3,1])
@result{} @{
  [1,1] =

     1   5   9
     2   6  10
     3   7  11

  [2,1] =

     4   8  12

  [1,2] =

    13
    14
    15

  [2,2] = 16
@}
@end group
@end example
@seealso{num2cell, cell2mat}
@end deftypefn 