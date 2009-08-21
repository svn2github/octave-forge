md5="6c927b02e1193c16d6e6704c6be834b6";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{x}, @var{xdot}, @var{t_out}, @var{istat}, @var{msg}] =} dasrt (@var{fcn} [, @var{g}], @var{x_0}, @var{xdot_0}, @var{t} [, @var{t_crit}])
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

La soluci@'on se retorna en las matrices @var{x} y @var{xdot},
en donde cada fila en las matrices resultantes corresponde a uno 
de los elementos en el vector @var{t_out}. El primer elemento de @var{t}
deber@'ia ser @math{t_0} y corresponder al estado inicial del sistema 
@var{x_0} y su derivada @var{xdot_0}, tal que la primer fila
de la salida @var{x} es @var{x_0} y la primera fila 
de la salida @var{xdot} es @var{xdot_0}.

El vector @var{t} provee un l@'imite superior para el intervalo de 
integraci@'on. Si se cumple la condici@'on de parada, el vector 
@var{t_out} ser@'a mas corto que @var{t}, y el elemento final de 
@var{t_out} ser@'a el punto en donde se cumpli@'o el criterio de parada, 
y puede no corresponder con elemento alguno del vector @var{t}.

El primer argumento, @var{fcn}, es una cadena, o arreglo de cadenas o
en l@'inea o manejador de funci@'on, que nombra la funci@'on a llamar 
para calcular el vector de residuos para el conjunto de ecuaciones. 
Debe tener la forma:

@example
@var{res} = f (@var{x}, @var{xdot}, @var{t})
@end example

@noindent
en donde @var{x}, @var{xdot}, y @var{res} son vectores, y @var{t} es un 
escalar.

Si @var{fcn} es un arreglo cadena de dos elementos, o un arreglo de dos celdas, 
el primer elemento nombra la funci@'on @math{f} descrita anteriormente, y el 
segundo elemento nombra una funci@'on que calcula el Jacobiano modificado 

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

La funci@'on Jacobiano modificado debe tener la forma 

@example

@var{jac} = j (@var{x}, @var{xdot}, @var{t}, @var{c})

@end example

El segundo argumento opcional nombra a la funci@'on que define las 
funciones de restricci@'on cuyas raices son deseadas durante la 
integraci@'on. Esta funci@'on debe tener la forma

@example
@var{g_out} = g (@var{x}, @var{t})
@end example

y retornar un vector de los valores de la funci@'on de restricci@'on.
Si el valor de alguna restricci@'on cambia de signo, @sc{Dasrt}
intentar@'a detener la integraci@'on en el punto en donde el signo cambia.

Si se omite el nombre de la funci@'on de restricci@'on, @code{dasrt} resuelve 
el mismo problema que @code{daspk} o @code{dassl}.

N@'otese que debido a los errores num@'ericos en las funciones de restricci@'on 
debido al redondeo y al error de integraci@'on, @sc{Dasrt} puede retornar raices 
falsas, o retornar la misma raiz en dos o mas carcanamente iguales valores de 
@var{T}. Si se sospecha de tales raices falsas, el usuario deber@'ia considerar 
tolerancias de error menores o mayor precisi@'on en la evaluaci@'on de las 
funciones de restricci@'on.

Si una raiz de alguna funci@'on de restricci@'on define el fin del problema, 
la entrada de @sc{Dasrt} deber@'ia permitir la integraci@'on hasta un punto 
ligeramente despu@'es de aquella raiz, de tal forma que @sc{Dasrt} puede 
localizar la raiz mediante interpolaci@'on.

El tercer y cuarto argumentos de @code{dasrt} especifican la condici@'on 
inicial de los estados y sus derivadas, y el cuarto argumento especifica 
un vector de tiempos de salida en los cuales se desea la soluci@'on, 
incluyendo el tiempo correspondiente a la condici@'on inicial.

El conjunto de estados iniciales y derivadas no requieren ser consistentes.  
En la pr@'actica, sin embargo, @sc{Dassl} no es muy bueno para determinar 
si un sistema es consistente, lo mejor es asegurar que los valores iniciales 
se obtienen al evaluar la funi@'on en cero.

El sexto argumento es opcional, y puede ser usado para especificar el conjunto 
de tiempos que el solucionador DAE no deber@'ia integrar en el pasado. Esto 
es @'util para evitar dificultades con singularidades y puntos donde existen 
discontinuidades en las derivadas.

Despu@'es de un c@'alculo exitoso, el valor de @var{istate} ser@'a 
mayor que cero (consistente con la versi@'on de Fortran de @sc{Dassl}).

Si el c@'alculo no es exitoso, el valor de @var{istate} ser@'a 
menor que cero y @var{msg} tendr@'a informaci@'on adicional.

Usted puede usar la funci@'on @code{dasrt_options} para establecer 
par@'ametros opcionales para @code{dasrt}.
@seealso{daspk, dasrt, lsode}
@end deftypefn
