md5="5cc38ccdbf0d1366171084ec32793cf1";rev="6224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{x}, @var{xdot}, @var{istate}, @var{msg}] =} dassl (@var{fcn}, @var{x_0}, @var{xdot_0}, @var{t}, @var{t_crit})
Resuelve el conjunto de ecuaciones algebreico-diferenciales 
@iftex
@tex
$$ 0 = f (x, \dot{x}, t) $$
con
$$ x(t_0) = x_0, \dot{x}(t_0) = \dot{x}_0 $$
@end tex
@end iftex
@ifinfo

@example
0 = f (x, xdot, t)
@end example

@noindent
con

@example
x(t_0) = x_0, xdot(t_0) = xdot_0
@end example

@end ifinfo
La soluci@'on se retorna en las matrices @var{x} y @var{xdot},
en donde cada fila en las matrices resultantes corresponde a uno 
de los elementos del vector @var{t}. El primer elemento de @var{t}
deber@'ia ser @math{t_0} y corresponder con el estado inicial del 
sistema @var{x_0} y sus derivadas @var{xdot_0}, tal que la primera fila 
de la salida @var{x} es @var{x_0} y la primera fila de la salida 
@var{xdot} es @var{xdot_0}.

El primer argumento, @var{fcn}, es una cadena o un arreglo de dos celdas 
de cadenas, en l@'inea o manejador de funci@'on, que nombra la funci@'on, 
para llamar a calcular el vector de residuos del conjunto de ecuaciones. 
Este debe tener la forma 

@example
@var{res} = f (@var{x}, @var{xdot}, @var{t})
@end example

@noindent
en donde @var{x}, @var{xdot}, y @var{res} son vectores, y @var{t} es un 
escalar.

Si @var{fcn} es un arreglo de cadenas de dos elementos, el primer 
elemento nombra la funci@'on @math{f} descrita anteriormente, y el 
segundo elemento nombra una funci@'on para calcular el Jacobiano 
modificado

@iftex
@tex
$$
J = {\partial f \over \partial x}
  + c {\partial f \over \partial \dot{x}}
$$
@end tex
@end iftex
@ifinfo
@example
      df       df
jac = -- + c ------
      dx     d xdot
@end example
@end ifinfo

El Jacabiano modificado debe tener la forma 

@example

@var{jac} = j (@var{x}, @var{xdot}, @var{t}, @var{c})

@end example

El segundo y tercer argumento de @code{dassl} especifican la condici@'on 
inicial de los estados y sus derivadas, y el cuarto argumento 
especifica un vector de tiempos de salida en los cuales la salida 
es deseada, incluyendo el tiempo correspondiente a la condici@'on 
inicial.

El conjunto de estados iniciales y derivadas no son estrictamente requeridos 
que sean consistentes. En la pr@'actica, sin embargo, @sc{Dassl} no es muy bueno 
determinando la consistencia de un conjunto, lo mejor es asegurar que 
los valores iniciales resultan en la funci@'on evaluada en cero.

El quinto argumento es opcional, y puede ser usado para especificar el conjunto de 
tiempos en los cuales el solucionador DAE no deber@'ia integrar en el pasado. Esto 
es @'util para evitar dificultades con singularidades y puntos de discontinuidad 
en las derivadas.

Despu@'es del c@'alculo exitoso, el valor de @var{istate} ser@'a 
mayor que cero (consistente con la versi@'on en Fortran de @sc{Dassl}).

Si el c@'alculo no es exitoso, el valor de @var{istate} ser@'a 
menor que cero y @var{msg} tendr@'a informaci@'on adicional.

La funci@'on @code{dassl_options} puede ser usada para especificar 
par@'ametros opcionales de @code{dassl}.
@seealso{daspk, dasrt, lsode}
@end deftypefn
