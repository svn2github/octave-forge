md5="2bd24a76ff1856a0620addb794ddbab5";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {[@var{x}, @var{info}, @var{msg}] =} fsolve (@var{fcn}, @var{x0})
Dada @var{fcn}, el nombre de una función de la forma @code{f (@var{x})} 
y el punto inicial @var{x0}, @code{fsolve} resuelve el conjunto de ecuaciones 
tal que @code{f(@var{x}) == 0}.

Si @var{fcn} es un arreglo de cadenas de dos elementos, o un arreglo de celdas de dos elementos 
con el nombre de la función en línea o un apuntador de función. El primer 
elemento describe la función @math{f} mencionada anteriormente, y el segundo 
elemento describe una función de la forma @code{j (@var{x})} para calcular la 
matriz Jacobiana con elementos 
@tex
$$ J = {\partial f_i \over \partial x_j} $$
@end tex
@ifinfo

@example
           df_i
jac(i,j) = ----
           dx_j
@end example
@end ifinfo

Se puede usar la función @code{fsolve_options} para establecer los 
parámetros opcionales de @code{fsolve}.
@end deftypefn
