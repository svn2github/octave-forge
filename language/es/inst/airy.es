md5="d385a09dcabc09c954e784f13e31ad08";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {[@var{a}, @var{ierr}] =} airy (@var{k}, @var{z}, @var{opt})
Calcula las funciones Airy de primera y segunda clase, y sus 
derivadas.

@example
 K   Función  Coeficiente (Si 'opt' es definido)
---  --------   ---------------------------------------
 0   Ai (Z)     exp ((2/3) * Z * sqrt (Z))
 1   dAi(Z)/dZ  exp ((2/3) * Z * sqrt (Z))
 2   Bi (Z)     exp (-abs (real ((2/3) * Z *sqrt (Z))))
 3   dBi(Z)/dZ  exp (-abs (real ((2/3) * Z *sqrt (Z))))
@end example

El llamado de la función @code{airy (@var{z})} es equivalente a
@code{airy (0, @var{z})}.

El resultado es del mismo tamaño que @var{z}.

Si es requerido, @var{ierr} contiene la siguiente información de estado y
el mismo tamaño que el resultado.

@enumerate 0
@item
Normal, returna.
@item
Error al introducir los datos, returna @code{NaN}.
@item
Desbordamiento, returna @code{Inf}.
@item
Pérdida de cifras significativas por reducción de los argumentos resulta 
en menos de la mitad de la precisión de la máquina.
@item
Pérdida complete de cifras significativas por reducción de los argumentos, 
returna @code{NaN}.
@item
Error---no cálculo,  condición de termination del algoritmo no cumplida,
returna @code{NaN}.
@end enumerate
@end deftypefn
