md5="90ef11ebcf1efdf954fbbe9f607ea593";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {[@var{x}, @var{xdot}, @var{istate}, @var{msg}] =} daspk (@var{fcn}, @var{x_0}, @var{xdot_0}, @var{t}, @var{t_crit})
Resuelve el conjunto de ecuaciones diferencial-algebráicas
@tex
$$ 0 = f (x, \dot{x}, t) $$
with
$$ x(t_0) = x_0, \dot{x}(t_0) = \dot{x}_0 $$
@end tex
@ifinfo

@example
0 = f (x, xdot, t)
@end example

con

@example
x(t_0) = x_0, xdot(t_0) = xdot_0
@end example

@end ifinfo
La solución se retorna en las matrices @var{x} y @var{xdot},
en donde cada fila en la matriz resultante corresponde con uno de los 
elementos en el vector @var{t}. El primer elemento de @var{t}
debería ser @math{t_0} y corresponde al estado inicial del 
sistema @var{x_0} y su derivada @var{xdot_0}, tal que la primera 
fila de la salida @var{x} es @var{x_0} y la primera fila 
de la salida @var{xdot} es @var{xdot_0}.

El primer argumento, @var{fcn}, es una cadena o un arreglo de dos elementos 
de cadenas , inline o apuntador de función, que nombra la función, a llamar 
para calcular el vector de residuos para el conjunto de ecuaciones. Debe tener 
la forma

@example
@var{res} = f (@var{x}, @var{xdot}, @var{t})
@end example

@noindent
en donde @var{x}, @var{xdot}, y @var{res} son vectors, y @var{t} es un
escalar.

Si @var{fcn} es un arreglo de caracteres de dos elementos, el primer elemento nombra 
la función @math{f} descrita anteriormente, y el segundo elemento nombra 
una función para calcular el Jacobiano modificado 
@tex
$$
J = {\partial f \over \partial x}
  + c {\partial f \over \partial \dot{x}}
$$
@end tex
@ifinfo

@example
      df       df
jac = -- + c ------
      dx     d xdot
@end example
@end ifinfo

El Jacobiano modificado debe ser de la forma

@example

@var{jac} = j (@var{x}, @var{xdot}, @var{t}, @var{c})

@end example

El segundo y tercer argumento de @code{daspk} especifican las condiciones
iniciales de los estados y sus derivadas, y el cuarto argumento 
especifica un vector de tiempos de salida en donde se desea la solución,
incluyendo el tiempo correspondiente a la condición inicial.

No es requerido que el conjunto de estados iniciales y derivadas sea consistente. 
Si no son consistentes, se deve usar la función
@code{daspk_options} para suministrar información adicional para 
que @code{daspk} pueda calcular un punto inicial consistente.

El quinto argumento es opcional, y puede ser usado para especificar un conjunto de
tiempos que el solucionador DAE no debería integrar. Esto es útil para evitar
dificultades con singularidades y puntos donde existen discontinuidades en la derivada.

Después de una computación exitosa, el valor de @var{istate} será 
mayor que cero (consistente con la versión de Fortran de @sc{Daspk}).

Si la computación no es exitosa, el valor de @var{istate} será
menor que cero y @var{msg} tendrá información adicional.

Puede usar la función @code{daspk_options} para ajustar los parámetros 
opcionales de @code{daspk}.
@seealso{dassl}
@end deftypefn
