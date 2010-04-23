md5="6c927b02e1193c16d6e6704c6be834b6";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {[@var{x}, @var{xdot}, @var{t_out}, @var{istat}, @var{msg}] =} dasrt (@var{fcn} [, @var{g}], @var{x_0}, @var{xdot_0}, @var{t} [, @var{t_crit}])
Resuelve el conjunto de ecuaciones algebraico-diferenciales
@tex
$$ 0 = f (x, \dot{x}, t) $$
con
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
con criterio de parada funcional (encontrar las raices).

La solución se retorna en las matrices @var{x} y @var{xdot},
en donde cada fila en las matrices resultantes corresponde a uno 
de los elementos en el vector @var{t_out}. El primer elemento de @var{t}
debería ser @math{t_0} y corresponder al estado inicial del sistema 
@var{x_0} y su derivada @var{xdot_0}, tal que la primer fila
de la salida @var{x} es @var{x_0} y la primera fila 
de la salida @var{xdot} es @var{xdot_0}.

El vector @var{t} provee un límite superior para el intervalo de 
integración. Si se cumple la condición de parada, el vector 
@var{t_out} será mas corto que @var{t}, y el elemento final de 
@var{t_out} será el punto en donde se cumplió el criterio de parada, 
y puede no corresponder con elemento alguno del vector @var{t}.

El primer argumento, @var{fcn}, es una cadena, o arreglo de cadenas o
en línea o apuntador de función, que nombra la función a llamar 
para calcular el vector de residuos para el conjunto de ecuaciones. 
Debe tener la forma:

@example
@var{res} = f (@var{x}, @var{xdot}, @var{t})
@end example

@noindent
en donde @var{x}, @var{xdot}, y @var{res} son vectores, y @var{t} es un 
escalar.

Si @var{fcn} es un arreglo cadena de dos elementos, o un arreglo de dos celdas, 
el primer elemento nombra la función @math{f} descrita anteriormente, y el 
segundo elemento nombra una función que calcula el Jacobiano modificado 

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

La función Jacobiano modificado debe tener la forma 

@example

@var{jac} = j (@var{x}, @var{xdot}, @var{t}, @var{c})

@end example

El segundo argumento opcional nombra a la función que define las 
funciones de restricción cuyas raices son deseadas durante la 
integración. Esta función debe tener la forma

@example
@var{g_out} = g (@var{x}, @var{t})
@end example

y retornar un vector de los valores de la función de restricción.
Si el valor de alguna restricción cambia de signo, @sc{Dasrt}
intentará detener la integración en el punto en donde el signo cambia.

Si se omite el nombre de la función de restricción, @code{dasrt} resuelve 
el mismo problema que @code{daspk} o @code{dassl}.

Nótese que debido a los errores numéricos en las funciones de restricción 
debido al redondeo y al error de integración, @sc{Dasrt} puede retornar raices 
falsas, o retornar la misma raiz en dos o mas carcanamente iguales valores de 
@var{T}. Si se sospecha de tales raices falsas, el usuario debería considerar 
tolerancias de error menores o mayor precisión en la evaluación de las 
funciones de restricción.

Si una raiz de alguna función de restricción define el fin del problema, 
la entrada de @sc{Dasrt} debería permitir la integración hasta un punto 
ligeramente después de aquella raiz, de tal forma que @sc{Dasrt} puede 
localizar la raiz mediante interpolación.

El tercer y cuarto argumentos de @code{dasrt} especifican la condición 
inicial de los estados y sus derivadas, y el cuarto argumento especifica 
un vector de tiempos de salida en los cuales se desea la solución, 
incluyendo el tiempo correspondiente a la condición inicial.

El conjunto de estados iniciales y derivadas no requieren ser consistentes.  
En la práctica, sin embargo, @sc{Dassl} no es muy bueno para determinar 
si un sistema es consistente, lo mejor es asegurar que los valores iniciales 
se obtienen al evaluar la funión en cero.

El sexto argumento es opcional, y puede ser usado para especificar el conjunto 
de tiempos que el solucionador DAE no debería integrar en el pasado. Esto 
es útil para evitar dificultades con singularidades y puntos donde existen 
discontinuidades en las derivadas.

Después de un cálculo exitoso, el valor de @var{istate} será 
mayor que cero (consistente con la versión de Fortran de @sc{Dassl}).

Si el cálculo no es exitoso, el valor de @var{istate} será 
menor que cero y @var{msg} tendrá información adicional.

Usted puede usar la función @code{dasrt_options} para establecer 
parámetros opcionales para @code{dasrt}.
@seealso{daspk, dasrt, lsode}
@end deftypefn
