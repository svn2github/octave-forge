md5="f8d2e096f403a3b831e6ec1dc93541c2";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{xopt}, @var{fmin}, @var{status}, @var{extra}] =} glpk (@var{c}, @var{a}, @var{b}, @var{lb}, @var{ub}, @var{ctype}, @var{vartype}, @var{sense}, @var{param})
Resuelve un programa lineal usando la libreria GNU GLPK. Dados tres 
argumentos, @code{glpk} soluciona el siguiente programa lineal est@'andar:

@iftex
@tex
$$
  \min_x C^T x
$$
@end tex
@end iftex
@ifnottex
@example
min C'*x
@end example
@end ifnottex

sujeto a 

@iftex
@tex
$$
  Ax = b \qquad x \geq 0
$$
@end tex
@end iftex
@ifnottex
@example
@group
A*x  = b
  x >= 0
@end group
@end example
@end ifnottex

pero tambi@'en puede solucionar problemas de las forma 

@iftex
@tex
$$
  [ \min_x | \max_x ] C^T x
$$
@end tex
@end iftex
@ifnottex
@example
[ min | max ] C'*x
@end example
@end ifnottex

sujeto a 

@iftex
@tex
$$
 Ax [ = | \leq | \geq ] b \qquad  LB \leq x \leq UB
$$
@end tex
@end iftex
@ifnottex
@example
@group
A*x [ "=" | "<=" | ">=" ] b
  x >= LB
  x <= UB
@end group
@end example
@end ifnottex

Argumentos de entrada: 

@table @var
@item c
Arreglo columna con los coeficientes de la funci@'on objetivo.

@item a
Matriz con los coeficientes de las restricciones.

@item b
Arreglo columna con los valores del lado derecho para cada restricci@'on 
de la matriz de restricciones.

@item lb
Arreglo con el l@'imite inferior de cada una de las variables. Si 
no se suministra @var{lb}, el valor predetermiando del l@'imite inferior de 
las variables es cero.

@item ub
Arreglo con el l@'imite superior de cada una de las variables. Si 
no se suministra @var{ub}, el valor predetermiando del l@'imite superior de 
las variables es infinito.

@item ctype
Arreglo de caracteres con el sentido de cada restricci@'on en la 
matriz de restricciones. Cada elemento del arreglo puede tomar uno de los 
siguientes valores 
@table @code
@item "F"
Restricci@'on libre (no acotada) (se ignora la restricci@'on).
@item "U"
Restrici@'on de desigualdad con l@'imite superior (@code{A(i,:)*x <= b(i)}).
@item "S"
Restricci@'on de igualdad (@code{A(i,:)*x = b(i)}).
@item "L"
Restrici@'on de desigualdad con l@'imite inferior (@code{A(i,:)*x >= b(i)}).
@item "D"
Restricci@'on de desigualdad con l@'imite inferior y superior 
(@code{A(i,:)*x >= -b(i)} @emph{y} (@code{A(i,:)*x <= b(i)}).
@end table

@item vartype
Arreglo columna con los tipos de las variables.
@table @code
@item "C"
Variable continua.
@item "I"
Variable entera.
@end table

@item sense
Si @var{sense} es 1, el problema es una minimizaci@'on. Si @var{sense} es 
-1, el problema es una maximizaci@'on. El valor predetermiando es 1.

@item param
Estructura con los par@'ametros usados para definir el comportamiento del 
solucionador. Los elementos ausentes en la estructura toman los valores 
predeterminados, de tal forma que solo se requieren los elementos que van a 
ser cambiados.

Par@'ametros enteros:

@table @code
@item msglev (@code{LPX_K_MSGLEV}, predeterminado: 1)
Nivel de los mensajes de salida de las rutinas del solucionador: 
@table @asis
@item 0
Ninguna salida.
@item 1
Solo mensajes de error.
@item 2
Salida normal.
@item 3
Salida completa (incluye mensajes informativos).
@end table

@item scale (@code{LPX_K_SCALE}, predeterminado: 1)
Opciones de escala: 
@table @asis
@item 0
Ninguna escala.
@item 1
Escala equilibrada.
@item 2
Escala de media geom@'etrica, por lo tanto escala equilibrada.
@end table

@item dual	 (@code{LPX_K_DUAL}, predeterminado: 0)
Opci@'on de simplex dual: 
@table @asis
@item 0
No use el simplex dual.
@item 1
Si la soluci@'on b@'asica inicial es factible en el dual, use el simplex dual.
@end table

@item price	 (@code{LPX_K_PRICE}, predeterminado: 1)
Opti@'on de precio (para el simplex principal y dual):
@table @asis
@item 0
Precio del libro.
@item 1
Precio del borde de descenso m@'as r@'apido.
@end table
  
@item round	 (@code{LPX_K_ROUND}, predeterminado: 0)
Opci@'on del redondeo de la soluci@'on: 
@table @asis
@item 0
Reporta todos los valores del principal y dual "como es".
@item 1
Reemplaza los valores peque@~{n}os del principal y dual por cero. 
@end table

@item itlim	 (@code{LPX_K_ITLIM}, predeterminado: -1)
L@'imite de las iteraciones del simplex. Si este valor es positivo, se 
reduce en una unidad cada vez que se realiza una iteraci@'on del simplex. 
Cuando llega a cero, el solucionador se detiene. Un valor negativo indica 
que las iteraciones no tienen l@'imite.

@item itcnt (@code{LPX_K_OUTFRQ}, predeterminado: 200)
Frecuencia de salida, en iteraciones. Este par@'ametro especifica con 
cuanta frecuencia el solucionador envia informaci@'on acerca de la 
soluci@'on a la salida est@'andar. 

@item branch (@code{LPX_K_BRANCH}, predeterminado: 2)
Opci@'on de heur@'istica de bifurcaci@'on (solo para MIP):
@table @asis
@item 0
Bifurcaci@'n en la primera variable.
@item 1
Bifurcaci@'n en la @'ultima variable.
@item 2
Bifurcaci@'n usando la heur@'istica de Driebeck y Tomlin.
@end table

@item btrack (@code{LPX_K_BTRACK}, predeterminado: 2)
Opci@'on de heur@'istica recorrido (solo para MIP):
@table @asis
@item 0
B@'usqueda por profundidad.
@item 1
B@'usqueda por anchura.
@item 2
Recorrido usando la mejor heur@'istica de proyecci@'on.
@end table

@item presol (@code{LPX_K_PRESOL}, predeterminado: 1)
Si se establece este indicador, se usa la rutina @code{lpx_simplex} 
para preresolver el problema. En otro caso no se usa el presolucionador 
de programas lineales.

@item lpsolver (predeterminado: 1)
Seleciona el solucionador que ser@'a utilizado. Si el problema es de tipo 
MIP, esta varible ser@'a ignorada.
@table @asis
@item 1
M@'etodo simplex revisado.
@item 2
M@'etodo de punto interior.
@end table
@item save (predeterminado: 0)
Si este par@'ametro es distinto de cero, guarda una copia del problema en 
el archivo @file{"outpb.lp"} en formato CPLEX LP. Actualmente no hay forma 
de cambiar el nombre del archivo de salida.
@end table

Par@'ametros reales:

@table @code
@item relax (@code{LPX_K_RELAX}, predeterminado: 0.07)
Par@'ametro de relajaci@'on usado en la prueba de proporci@'on. Si es cero, e 
usa la proporci@'on del libro. Si es distinto de cero (deber@'ia ser 
positivo), se usa la prueba de proporci@'on de dos pasos de Harris. En el 
@'ultimo caso, se permite que el primer paso de la prueba de proporci@'on 
de las variables b@'asicas (en el caso del simplex principal) o costos, 
sobrepasen ligeramente sus l@'imites, pero no m@'as que @code{relax*tolbnd} 
o @code{relax*toldj (de modo que, @code{relax} es un porcentaje de 
@code{tolbnd} o @code{toldj}}.

@item tolbnd (@code{LPX_K_TOLBND}, predeterminado: 10e-7)
Toleracia relativa usada para verificar si la soluci@'on b@'asica actual es 
factible en el principal. No se recomienda cambiar este par@'ametro a menos 
que se tenga conocimiento detallado de las implicaciones de este cambio.

@item toldj (@code{LPX_K_TOLDJ}, predeterminado: 10e-7)
Tolerancia absoluta usada para verificar si la soluci@'on b@'asica actual es 
factible en el dual. No se recomienda cambiar este par@'ametro a menos 
que se tenga conocimiento detallado de las implicaciones de este cambio.

@item tolpiv (@code{LPX_K_TOLPIV}, predeterminado: 10e-9)
Toleracia relativa usada para escoger dentro de los elementos pivote 
elegibles de la tabla del simplex. No se recomienda cambiar este par@'ametro 
a menos que se tenga conocimiento detallado de las implicaciones de este 
cambio.

@item objll (@code{LPX_K_OBJLL}, predeterminado: -DBL_MAX)
L@'imite inferior de la funci@'on objetivo. Si durante la segunda fase 
la funci@'on objetivo alcanza este l@'imite y continua descendiendo, el 
solucionador detiene la b@'usqueda. Este par@'ametro se usa solomente en 
el m@'etodo simplex dual.

@item objul (@code{LPX_K_OBJUL}, predeterminado: +DBL_MAX)
L@'imite superior de la funci@'on objetivo. Si durante la segunda fase 
la funci@'on objetivo alcanza este l@'imite y continua ascendiendo, el 
solucionador detiene la b@'usqueda. Este par@'ametro se usa solomente en 
el m@'etodo simplex dual.

@item tmlim (@code{LPX_K_TMLIM}, predeterminado: -1.0)
Tiempo l@'imite de b@'usqueda, en segundos. Si este valor es positivo, se 
reduce cada vez que se realiza una iteraci@'on por la cantidad de tiempo 
empleado en la iteraci@'on. Cuando llega a cero, se envia una se@~{n}al al 
solucionador para que termine la b@'usqueda. Los valores negativos implican 
b@'usquedas no limitadas por el tiempo.

@item outdly (@code{LPX_K_OUTDLY}, predeterminado: 0.0)
Retardo de salida, en segundos. Este par@'ametro especifica cuanto tiempo 
tardar@'a el solucionador en enviar la informaci@'on acerca de la soluci@'on 
a la salida est@'andar. Un valor no positivo implica que no hay retardo.

@item tolint (@code{LPX_K_TOLINT}, predeterminado: 10e-5)
Toleracia relativa usada para verifiacar si la soluci@'on actual b@'asica 
es entera factible. No se recomienda cambiar este par@'ametro a menos que 
se tenga conocimiento detallado de las implicaciones de este cambio.

@item tolobj (@code{LPX_K_TOLOBJ}, predeterminado: 10e-7)
Toleracia relativa usada para verificar si el valor de la funci@'on objetivo 
no es mejor que la mejor soluci@' entera factible conocida. No se recomienda 
cambiar este par@'ametro a menos que se tenga conocimiento detallado de las 
implicaciones de este cambio.
@end table
@end table

Valores de salida:

@table @var
@item xopt
Optimizador (el valor de las variables de dicisi@'on en el @'optimo).
@item fopt
El @'optimo de la funci@'on objetivo.
@item status
Estado de la optimizaci@'on.

M@'etodo Simplex:
@table @asis
@item 180 (@code{LPX_OPT})
La soluci@'on es @'optima.
@item 181 (@code{LPX_FEAS})
La soluci@'on es factible.
@item 182 (@code{LPX_INFEAS})
La soluci@'on no es factible.
@item 183 (@code{LPX_NOFEAS})
El problema no tiene soluci@'on factible.
@item 184 (@code{LPX_UNBND})
El problema no tiene soluci@'on acotada.
@item 185 (@code{LPX_UNDEF})
Es estado de la soluci@'on es indefinido.
@end table

M@'etodo de punto interior:
@table @asis
@item 150 (@code{LPX_T_UNDEF})
El m@'etodo de punto interior es indefinido.
@item 151 (@code{LPX_T_OPT})
El m@'etodo de punto interior es @'optimo.
@end table

M@'etodo entero mixto:
@table @asis
@item 170 (@code{LPX_I_UNDEF})
Es estado es indefinido.
@item 171 (@code{LPX_I_OPT})
La soluci@'on es entera @'optima.
@item 172 (@code{LPX_I_FEAS})
La soluci@'on es entera factible pero su optimalidad no ha sido probada.
@item 173 (@code{LPX_I_NOFEAS})
No existe soluci@'on entera factible.
@end table
@noindent
Si ocurre un error, @var{status} contiene uno de los siguiente c@'odigos:

@table @asis
@item 204 (@code{LPX_E_FAULT})
No es posible iniciar la b@'usqueda.
@item 205 (@code{LPX_E_OBJLL})
Se ha alcanzado el l@'imite inferior de la funci@'on objetivo.
@item 206 (@code{LPX_E_OBJUL})
Se ha alcanzado el l@'imite superior de la funci@'on objetivo.
@item 207 (@code{LPX_E_ITLIM})
L@'imite de iteraciones agotado.
@item 208 (@code{LPX_E_TMLIM})
Tiempo l@'imite agotado.
@item 209 (@code{LPX_E_NOFEAS})
No existe soluci@'on factible.
@item 210 (@code{LPX_E_INSTAB})
Inestabilidad num@'erica.
@item 211 (@code{LPX_E_SING})
Problemas con la matriz de bases.
@item 212 (@code{LPX_E_NOCONV})
No existe convergencia (interior).
@item 213 (@code{LPX_E_NOPFS})
No existe soluci@'on principal factible (presolucionador de programas 
lineales).
@item 214 (@code{LPX_E_NODFS})
No existe soluci@'on dual factuble (presolucionador de programas 
lineales).
@end table
@item extra
Estructura de datos con los siguientes campos:
@table @code
@item lambda
Variables del problema dual.
@item redcosts
Costos reducidos.
@item time
Tiempo (en segundos) usado para resolver los problemas LP/MIP.
@item mem
Memoria (en bytes) usada para resolver problemas LP/MIP (esta no est@'a 
disponible si la versi@'on de GLPK es 4.15 o posterior).
@end table
@end table

Ejemplo:

@example
@group
c = [10, 6, 4]';
a = [ 1, 1, 1;
     10, 4, 5;
      2, 2, 6];
b = [100, 600, 300]';
lb = [0, 0, 0]';
ub = [];
ctype = "UUU";
vartype = "CCC";
s = -1;

param.msglev = 1;
param.itlim = 100;

[xmin, fmin, status, extra] = ...
   glpk (c, a, b, lb, ub, ctype, vartype, s, param);
@end group
@end example
@end deftypefn
