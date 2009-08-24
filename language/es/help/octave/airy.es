md5="d385a09dcabc09c954e784f13e31ad08";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{a}, @var{ierr}] =} airy (@var{k}, @var{z}, @var{opt})
Calcula las funciones Airy de primera y segunda clase, y sus 
derivadas.

@example
 K   Funci@'on  Coeficiente (Si 'opt' es definido)
---  --------   ---------------------------------------
 0   Ai (Z)     exp ((2/3) * Z * sqrt (Z))
 1   dAi(Z)/dZ  exp ((2/3) * Z * sqrt (Z))
 2   Bi (Z)     exp (-abs (real ((2/3) * Z *sqrt (Z))))
 3   dBi(Z)/dZ  exp (-abs (real ((2/3) * Z *sqrt (Z))))
@end example

El llamado de la funci@'on @code{airy (@var{z})} es equivalente a
@code{airy (0, @var{z})}.

El resultado es del mismo tama@~no que @var{z}.

Si es requerido, @var{ierr} contiene la siguiente informaci@'on de estado y
el mismo tama@~no que el resultado.

@enumerate 0
@item
Normal, returna.
@item
Error al introducir los datos, returna @code{NaN}.
@item
Desbordamiento, returna @code{Inf}.
@item
Pérdida de cifras significativas por reducci@'on de los argumentos resulta 
en menos de la mitad de la precisi@'on de la m@'aquina.
@item
Pérdida complete de cifras significativas por reducci@'on de los argumentos, 
returna @code{NaN}.
@item
Error---no c@'alculo,  condici@'on de termination del algoritmo no cumplida,
returna @code{NaN}.
@end enumerate
@end deftypefn
