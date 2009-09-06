md5="90ef11ebcf1efdf954fbbe9f607ea593";rev="6224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{x}, @var{xdot}, @var{istate}, @var{msg}] =} daspk (@var{fcn}, @var{x_0}, @var{xdot_0}, @var{t}, @var{t_crit})
Resuelve el conjunto de ecuaciones diferencial-algebr@'aicas
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
La soluci@'on se retorna en las matrices @var{x} y @var{xdot},
en donde cada fila en la matriz resultante corresponde con uno de los 
elementos en el vector @var{t}. El primer elemento de @var{t}
deber@'ia ser @math{t_0} y corresponde al estado inicial del 
sistema @var{x_0} y su derivada @var{xdot_0}, tal que la primera 
fila de la salida @var{x} es @var{x_0} y la primera fila 
de la salida @var{xdot} es @var{xdot_0}.

El primer argumento, @var{fcn}, es una cadena o un arreglo de dos elementos 
de cadenas , inline o manejador de funci@'on, que nombra la funci@'on, a llamar 
para calcular el vector de residuos para el conjunto de ecuaciones. Debe tener 
la forma

@example
@var{res} = f (@var{x}, @var{xdot}, @var{t})
@end example

@noindent
en donde @var{x}, @var{xdot}, y @var{res} son vectors, y @var{t} es un
escalar.

Si @var{fcn} es un arreglo de caracteres de dos elementos, el primer elemento nombra 
la funci@'on @math{f} descrita anteriormente, y el segundo elemento nombra 
una funci@'on para calcular el Jacobiano modificado 
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
especifica un vector de tiempos de salida en donde se desea la soluci@'on,
incluyendo el tiempo correspondiente a la condici@'on inicial.

No es requerido que el conjunto de estados iniciales y derivadas sea consistente. 
Si no son consistentes, se deve usar la funci@'on
@code{daspk_options} para suministrar informaci@'on adicional para 
que @code{daspk} pueda calcular un punto inicial consistente.

El quinto argumento es opcional, y puede ser usado para especificar un conjunto de
tiempos que el solucionador DAE no deber@'ia integrar. Esto es @'util para evitar
dificultades con singularidades y puntos donde existen discontinuidades en la derivada.

Despu@'es de una computaci@'on exitosa, el valor de @var{istate} ser@'a 
mayor que cero (consistente con la versi@'on de Fortran de @sc{Daspk}).

Si la computaci@'on no es exitosa, el valor de @var{istate} ser@'a
menor que cero y @var{msg} tendr@'a informaci@'on adicional.

Puede usar la funci@'on @code{daspk_options} para ajustar los par@'ametros 
opcionales de @code{daspk}.
@seealso{dassl}
@end deftypefn
