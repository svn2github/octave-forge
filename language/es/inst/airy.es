md5="d385a09dcabc09c954e784f13e31ad08";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {FunciÃ³n cargable} {[@var{a}, @var{ierr}] =} airy (@var{k}, @var{z}, @var{opt})
Calcula las funciones Airy de primera y segunda clase, y sus 
derivadas.

@example
 K   FunciÃ³n  Coeficiente (Si 'opt' es definido)
---  --------   ---------------------------------------
 0   Ai (Z)     exp ((2/3) * Z * sqrt (Z))
 1   dAi(Z)/dZ  exp ((2/3) * Z * sqrt (Z))
 2   Bi (Z)     exp (-abs (real ((2/3) * Z *sqrt (Z))))
 3   dBi(Z)/dZ  exp (-abs (real ((2/3) * Z *sqrt (Z))))
@end example

El llamado de la funciÃ³n @code{airy (@var{z})} es equivalente a
@code{airy (0, @var{z})}.

El resultado es del mismo tamaÃ±o que @var{z}.

Si es requerido, @var{ierr} contiene la siguiente informaciÃ³n de estado y
el mismo tamaÃ±o que el resultado.

@enumerate 0
@item
Normal, returna.
@item
Error al introducir los datos, returna @code{NaN}.
@item
Desbordamiento, returna @code{Inf}.
@item
PÃ©rdida de cifras significativas por reducciÃ³n de los argumentos resulta 
en menos de la mitad de la precisiÃ³n de la mÃ¡quina.
@item
PÃ©rdida complete de cifras significativas por reducciÃ³n de los argumentos, 
returna @code{NaN}.
@item
Error---no cÃ¡lculo,  condiciÃ³n de termination del algoritmo no cumplida,
returna @code{NaN}.
@end enumerate
@end deftypefn
